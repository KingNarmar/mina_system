import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/transaction_model.dart';
import '../services/transaction_approval_service.dart';
import '../services/transaction_code_service.dart';
import '../services/transaction_storage_service.dart';

class TransactionsRepo {
  TransactionsRepo({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client,
      _storageService = TransactionStorageService(
        supabaseClient: supabaseClient ?? Supabase.instance.client,
      ),
      _approvalService = TransactionApprovalService(
        supabase: supabaseClient ?? Supabase.instance.client,
      ),
      _codeService = TransactionCodeService(
        supabase: supabaseClient ?? Supabase.instance.client,
      );

  final SupabaseClient _supabase;
  final TransactionStorageService _storageService;
  final TransactionApprovalService _approvalService;
  final TransactionCodeService _codeService;

  static const String _transactionSelectColumns = '''
    id,
    company_id,
    transaction_code,
    transaction_type,
    worker_id,
    worker_hr_code_snapshot,
    worker_name_snapshot,
    worker_department_snapshot,
    worker_job_title_snapshot,
    tool_id,
    tool_code_snapshot,
    tool_name_snapshot,
    tool_unit_snapshot,
    tool_category_snapshot,
    quantity,
    proof_image_path,
    note,
    approval_required,
    approval_status,
    approval_document_path,
    approval_decision_note,
    approval_decided_by_profile_id,
    approval_decided_at,
    settlement_status,
    settlement_note,
    settled_by_profile_id,
    settled_at,
    created_by_profile_id,
    created_at,
    updated_at
  ''';

  Future<List<TransactionModel>> getTransactions({
    required String companyId,
  }) async {
    final data = await _supabase
        .from('transactions')
        .select(_transactionSelectColumns)
        .eq('company_id', companyId)
        .order('created_at', ascending: false);

    return data.map((item) {
      return TransactionModel.fromJson(item);
    }).toList();
  }

  Future<TransactionModel> addTransaction({
    required TransactionModel transaction,
  }) async {
    final transactionToInsert = await _prepareTransactionProofImage(
      transaction,
    );

    final data = await _supabase
        .from('transactions')
        .insert(transactionToInsert.toInsertJson())
        .select(_transactionSelectColumns)
        .single();

    return TransactionModel.fromJson(data);
  }

  Future<TransactionModel> updateTransaction({
    required String transactionId,
    required TransactionModel transaction,
  }) async {
    final transactionToUpdate = await _prepareTransactionProofImage(
      transaction,
    );

    final data = await _supabase
        .from('transactions')
        .update(transactionToUpdate.toUpdateJson())
        .eq('id', transactionId)
        .select(_transactionSelectColumns)
        .single();

    return TransactionModel.fromJson(data);
  }

  Future<TransactionModel> uploadApprovalDocument({
    required TransactionModel transaction,
    required String localDocumentPath,
  }) async {
    final transactionId = transaction.id;
    final companyId = transaction.companyId;

    if (transactionId == null || transactionId.trim().isEmpty) {
      throw StateError('Transaction ID was not found.');
    }

    if (companyId == null || companyId.trim().isEmpty) {
      throw StateError('Company ID was not found.');
    }

    if (!transaction.isLostOrDamaged) {
      throw StateError(
        'Approval document can be uploaded only for lost or damaged transactions.',
      );
    }

    if (!transaction.isApprovalPending) {
      throw StateError(
        'Approval document can be uploaded only while approval is pending.',
      );
    }

    final uploadedPath = await _storageService.uploadApprovalDocumentFile(
      companyId: companyId,
      transactionCode: transaction.transactionCode,
      localDocumentPath: localDocumentPath,
    );

    final data = await _supabase
        .from('transactions')
        .update({
          'approval_document_path': uploadedPath,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', transactionId)
        .eq('company_id', companyId)
        .select(_transactionSelectColumns)
        .single();

    return TransactionModel.fromJson(data);
  }

  Future<String> createApprovalDocumentSignedUrl({
    required TransactionModel transaction,
    int expiresInSeconds = 60 * 10,
  }) async {
    final companyId = transaction.companyId;
    final documentPath = transaction.approvalDocumentPath;

    if (companyId == null || companyId.trim().isEmpty) {
      throw StateError('Company ID was not found.');
    }

    if (documentPath == null || documentPath.trim().isEmpty) {
      throw StateError('Signed approval document was not found.');
    }

    if (!_storageService.isCloudStoragePath(
      documentPath,
      companyId: companyId,
    )) {
      throw StateError('Invalid approval document storage path.');
    }

    return _storageService.createSignedUrl(
      bucket: TransactionStorageService.approvalDocumentsBucket,
      path: documentPath,
      expiresInSeconds: expiresInSeconds,
    );
  }

  Future<TransactionModel> approveLostDamagedTransaction({
    required TransactionModel transaction,
    required String decidedByProfileId,
    String? decisionNote,
  }) async {
    return _approvalService.approveLostDamagedTransaction(
      transaction: transaction,
      decidedByProfileId: decidedByProfileId,
      selectColumns: _transactionSelectColumns,
      decisionNote: decisionNote,
    );
  }

  Future<TransactionModel> rejectLostDamagedTransaction({
    required TransactionModel transaction,
    required String decidedByProfileId,
    String? decisionNote,
  }) async {
    return _approvalService.rejectLostDamagedTransaction(
      transaction: transaction,
      decidedByProfileId: decidedByProfileId,
      selectColumns: _transactionSelectColumns,
      decisionNote: decisionNote,
    );
  }

  Future<TransactionModel> settleApprovedLostDamagedTransaction({
    required TransactionModel transaction,
    required String settledByProfileId,
    String? settlementNote,
  }) async {
    return _approvalService.settleApprovedLostDamagedTransaction(
      transaction: transaction,
      settledByProfileId: settledByProfileId,
      selectColumns: _transactionSelectColumns,
      settlementNote: settlementNote,
    );
  }

  Future<String> generateNextTransactionCode({
    required String companyId,
  }) async {
    return _codeService.generateNextTransactionCode(companyId: companyId);
  }

  Future<bool> transactionCodeExists({
    required String companyId,
    required String transactionCode,
    String? ignoredTransactionId,
  }) async {
    return _codeService.transactionCodeExists(
      companyId: companyId,
      transactionCode: transactionCode,
      ignoredTransactionId: ignoredTransactionId,
    );
  }

  Future<TransactionModel> _prepareTransactionProofImage(
    TransactionModel transaction,
  ) async {
    final companyId = transaction.companyId;
    final imagePath = transaction.imagePath;

    if (companyId == null || companyId.trim().isEmpty) {
      return transaction;
    }

    if (imagePath == null || imagePath.trim().isEmpty) {
      return transaction;
    }

    if (_storageService.isCloudStoragePath(imagePath, companyId: companyId)) {
      return transaction;
    }

    final uploadedPath = await _storageService.uploadProofImage(
      companyId: companyId,
      transactionCode: transaction.transactionCode,
      localImagePath: imagePath,
    );

    return transaction.copyWith(imagePath: uploadedPath);
  }
}
