import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';
import '../services/transaction_helper_service.dart';

class TransactionApprovalService {
  TransactionApprovalService({required SupabaseClient supabase})
    : _supabase = supabase;

  final SupabaseClient _supabase;

  Future<TransactionModel> approveLostDamagedTransaction({
    required TransactionModel transaction,
    required String decidedByProfileId,
    required String selectColumns,
    String? decisionNote,
  }) async {
    final transactionId = transaction.id;
    final companyId = transaction.companyId;

    if (transactionId == null || transactionId.trim().isEmpty) {
      throw StateError('Transaction ID was not found.');
    }

    if (companyId == null || companyId.trim().isEmpty) {
      throw StateError('Company ID was not found.');
    }

    if (decidedByProfileId.trim().isEmpty) {
      throw StateError('Approver profile ID was not found.');
    }

    if (!transaction.isLostOrDamaged) {
      throw StateError('Only lost or damaged transactions can be approved.');
    }

    if (!transaction.isApprovalPending) {
      throw StateError('Only pending transactions can be approved.');
    }

    if (transaction.approvalDocumentPath == null ||
        transaction.approvalDocumentPath!.trim().isEmpty) {
      throw StateError(
        'Signed approval document must be uploaded before approval.',
      );
    }

    final now = DateTime.now().toUtc().toIso8601String();

    final data = await _supabase
        .from('transactions')
        .update({
          'approval_status': 'approved',
          'approval_decision_note': TransactionHelperService.emptyToNull(
            decisionNote,
          ),
          'approval_decided_by_profile_id': decidedByProfileId.trim(),
          'approval_decided_at': now,
          'settlement_status': 'pending_settlement',
          'updated_at': now,
        })
        .eq('id', transactionId)
        .eq('company_id', companyId)
        .select(selectColumns)
        .single();

    return TransactionModel.fromJson(data);
  }

  Future<TransactionModel> rejectLostDamagedTransaction({
    required TransactionModel transaction,
    required String decidedByProfileId,
    required String selectColumns,
    String? decisionNote,
  }) async {
    final transactionId = transaction.id;
    final companyId = transaction.companyId;

    if (transactionId == null || transactionId.trim().isEmpty) {
      throw StateError('Transaction ID was not found.');
    }

    if (companyId == null || companyId.trim().isEmpty) {
      throw StateError('Company ID was not found.');
    }

    if (decidedByProfileId.trim().isEmpty) {
      throw StateError('Rejector profile ID was not found.');
    }

    if (!transaction.isLostOrDamaged) {
      throw StateError('Only lost or damaged transactions can be rejected.');
    }

    if (!transaction.isApprovalPending) {
      throw StateError('Only pending transactions can be rejected.');
    }

    if (transaction.approvalDocumentPath == null ||
        transaction.approvalDocumentPath!.trim().isEmpty) {
      throw StateError(
        'Signed approval document must be uploaded before rejection.',
      );
    }

    final now = DateTime.now().toUtc().toIso8601String();

    final data = await _supabase
        .from('transactions')
        .update({
          'approval_status': 'rejected',
          'approval_decision_note': TransactionHelperService.emptyToNull(
            decisionNote,
          ),
          'approval_decided_by_profile_id': decidedByProfileId.trim(),
          'approval_decided_at': now,
          'settlement_status': 'not_required',
          'settlement_note': null,
          'settled_by_profile_id': null,
          'settled_at': null,
          'updated_at': now,
        })
        .eq('id', transactionId)
        .eq('company_id', companyId)
        .select(selectColumns)
        .single();

    return TransactionModel.fromJson(data);
  }

  Future<TransactionModel> settleApprovedLostDamagedTransaction({
    required TransactionModel transaction,
    required String settledByProfileId,
    required String selectColumns,
    String? settlementNote,
  }) async {
    final transactionId = transaction.id;
    final companyId = transaction.companyId;

    if (transactionId == null || transactionId.trim().isEmpty) {
      throw StateError('Transaction ID was not found.');
    }

    if (companyId == null || companyId.trim().isEmpty) {
      throw StateError('Company ID was not found.');
    }

    if (settledByProfileId.trim().isEmpty) {
      throw StateError('Settlement profile ID was not found.');
    }

    if (!transaction.isLostOrDamaged) {
      throw StateError('Only lost or damaged transactions can be settled.');
    }

    if (!transaction.isApprovalApproved) {
      throw StateError(
        'Only approved lost or damaged transactions can be settled.',
      );
    }

    if (!transaction.isPendingSettlement) {
      throw StateError('Only transactions pending settlement can be settled.');
    }

    final now = DateTime.now().toUtc().toIso8601String();

    final data = await _supabase
        .from('transactions')
        .update({
          'settlement_status': 'settled',
          'settlement_note': TransactionHelperService.emptyToNull(
            settlementNote,
          ),
          'settled_by_profile_id': settledByProfileId.trim(),
          'settled_at': now,
          'updated_at': now,
        })
        .eq('id', transactionId)
        .eq('company_id', companyId)
        .select(selectColumns)
        .single();

    return TransactionModel.fromJson(data);
  }
}
