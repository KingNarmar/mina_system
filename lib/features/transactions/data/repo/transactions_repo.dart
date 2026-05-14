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
    approval_document_uploaded_by_profile_id,
    approval_document_uploaded_by_name_snapshot,
    approval_document_uploaded_by_email_snapshot,
    approval_document_uploaded_at,
    approval_decision_note,
    approval_decided_by_profile_id,
    approval_decided_by_name_snapshot,
    approval_decided_by_email_snapshot,
    approval_decided_at,
    settlement_status,
    settlement_note,
    settled_by_profile_id,
    settled_by_name_snapshot,
    settled_by_email_snapshot,
    settled_at,
    created_by_profile_id,
    created_by_name_snapshot,
    created_by_email_snapshot,
    proof_image_uploaded_by_profile_id,
    proof_image_uploaded_by_name_snapshot,
    proof_image_uploaded_by_email_snapshot,
    proof_image_uploaded_at,
    updated_by_profile_id,
    updated_by_name_snapshot,
    updated_by_email_snapshot,
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
    final companyId = transaction.companyId;
    final workerId = transaction.workerId;
    final toolId = transaction.toolId;

    if (companyId == null || companyId.trim().isEmpty) {
      throw StateError('Company ID was not found.');
    }

    if (workerId == null || workerId.trim().isEmpty) {
      throw StateError('Worker ID was not found.');
    }

    if (toolId == null || toolId.trim().isEmpty) {
      throw StateError('Tool ID was not found.');
    }

    final localProofImagePath = _readLocalProofImagePath(
      transaction: transaction,
      companyId: companyId,
    );

    final rpcResult = await _supabase.rpc(
      'create_custody_transaction',
      params: {
        'p_company_id': companyId,
        'p_worker_id': workerId,
        'p_tool_id': toolId,
        'p_transaction_type': _transactionTypeToDatabaseValue(transaction.type),
        'p_quantity': transaction.quantity,
        'p_proof_image_path': null,
        'p_note': _emptyToNull(transaction.note),
        'p_defer_proof_image_upload': localProofImagePath != null,
      },
    );

    final transactionId = _readCreatedTransactionId(rpcResult);

    var savedTransaction = await _fetchTransactionById(
      transactionId: transactionId,
      companyId: companyId,
    );

    if (localProofImagePath == null) {
      return savedTransaction;
    }

    final officialTransactionCode = savedTransaction.transactionCode.trim();

    if (officialTransactionCode.isEmpty ||
        !officialTransactionCode.startsWith('TRX-')) {
      throw StateError('Official transaction code was not returned.');
    }

    final uploadedPath = await _storageService.uploadProofImage(
      companyId: companyId,
      transactionCode: officialTransactionCode,
      localImagePath: localProofImagePath,
    );

    final proofRpcResult = await _supabase.rpc(
      'upload_transaction_proof_image',
      params: {
        'p_company_id': companyId,
        'p_transaction_id': transactionId,
        'p_proof_image_path': uploadedPath,
      },
    );

    final savedTransactionId = _readCreatedTransactionId(proofRpcResult);

    savedTransaction = await _fetchTransactionById(
      transactionId: savedTransactionId,
      companyId: companyId,
    );

    return savedTransaction;
  }

  Future<TransactionModel> updateTransaction({
    required String transactionId,
    required TransactionModel transaction,
  }) async {
    throw UnsupportedError(
      'General transaction editing is disabled. Use controlled transaction workflows instead.',
    );
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

    final rpcResult = await _supabase.rpc(
      'upload_transaction_approval_document',
      params: {
        'p_company_id': companyId,
        'p_transaction_id': transactionId,
        'p_approval_document_path': uploadedPath,
      },
    );

    final savedId = _readCreatedTransactionId(rpcResult);

    final data = await _supabase
        .from('transactions')
        .select(_transactionSelectColumns)
        .eq('id', savedId)
        .eq('company_id', companyId)
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
    String? decisionNote,
  }) async {
    return _approvalService.approveLostDamagedTransaction(
      transaction: transaction,
      selectColumns: _transactionSelectColumns,
      decisionNote: decisionNote,
    );
  }

  Future<TransactionModel> rejectLostDamagedTransaction({
    required TransactionModel transaction,
    String? decisionNote,
  }) async {
    return _approvalService.rejectLostDamagedTransaction(
      transaction: transaction,
      selectColumns: _transactionSelectColumns,
      decisionNote: decisionNote,
    );
  }

  Future<TransactionModel> settleApprovedLostDamagedTransaction({
    required TransactionModel transaction,
    String? settlementNote,
  }) async {
    return _approvalService.settleApprovedLostDamagedTransaction(
      transaction: transaction,
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

  Future<TransactionModel> _fetchTransactionById({
    required String transactionId,
    required String companyId,
  }) async {
    final data = await _supabase
        .from('transactions')
        .select(_transactionSelectColumns)
        .eq('id', transactionId)
        .eq('company_id', companyId)
        .single();

    return TransactionModel.fromJson(data);
  }

  String? _readLocalProofImagePath({
    required TransactionModel transaction,
    required String companyId,
  }) {
    final imagePath = transaction.imagePath?.trim();

    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    if (_storageService.isCloudStoragePath(imagePath, companyId: companyId)) {
      throw StateError(
        'Existing cloud proof image paths cannot be reused for new transactions.',
      );
    }

    return imagePath;
  }

  String _readCreatedTransactionId(dynamic rpcResult) {
    if (rpcResult is String && rpcResult.trim().isNotEmpty) {
      return rpcResult.trim();
    }

    if (rpcResult is List && rpcResult.isNotEmpty) {
      final firstItem = rpcResult.first;

      if (firstItem is String && firstItem.trim().isNotEmpty) {
        return firstItem.trim();
      }

      if (firstItem is Map<String, dynamic>) {
        final transactionId =
            firstItem['transaction_id'] as String? ??
            firstItem['upload_transaction_proof_image'] as String? ??
            firstItem['upload_transaction_approval_document'] as String? ??
            firstItem['approve_lost_damaged_transaction'] as String? ??
            firstItem['reject_lost_damaged_transaction'] as String? ??
            firstItem['settle_lost_damaged_transaction'] as String? ??
            firstItem['create_custody_transaction'] as String?;

        if (transactionId != null && transactionId.trim().isNotEmpty) {
          return transactionId.trim();
        }
      }
    }

    if (rpcResult is Map<String, dynamic>) {
      final transactionId =
          rpcResult['transaction_id'] as String? ??
          rpcResult['upload_transaction_proof_image'] as String? ??
          rpcResult['upload_transaction_approval_document'] as String? ??
          rpcResult['approve_lost_damaged_transaction'] as String? ??
          rpcResult['reject_lost_damaged_transaction'] as String? ??
          rpcResult['settle_lost_damaged_transaction'] as String? ??
          rpcResult['create_custody_transaction'] as String?;

      if (transactionId != null && transactionId.trim().isNotEmpty) {
        return transactionId.trim();
      }
    }

    throw StateError('Transaction ID was not returned.');
  }

  String _transactionTypeToDatabaseValue(TransactionType type) {
    switch (type) {
      case TransactionType.issue:
        return 'issue';
      case TransactionType.returnTool:
        return 'return';
      case TransactionType.lost:
        return 'lost';
      case TransactionType.damaged:
        return 'damaged';
    }
  }

  String? _emptyToNull(String? value) {
    final cleanValue = value?.trim();

    if (cleanValue == null || cleanValue.isEmpty) {
      return null;
    }

    return cleanValue;
  }
}
