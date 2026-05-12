import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';

class TransactionApprovalService {
  TransactionApprovalService({required SupabaseClient supabase})
    : _supabase = supabase;

  final SupabaseClient _supabase;

  Future<TransactionModel> approveLostDamagedTransaction({
    required TransactionModel transaction,
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

    final rpcResult = await _supabase.rpc(
      'approve_lost_damaged_transaction',
      params: {
        'p_company_id': companyId,
        'p_transaction_id': transactionId,
        'p_decision_note': _emptyToNull(decisionNote),
      },
    );

    final savedId = _readTransactionIdFromRpcResult(rpcResult);

    return _getTransactionById(
      transactionId: savedId,
      companyId: companyId,
      selectColumns: selectColumns,
    );
  }

  Future<TransactionModel> rejectLostDamagedTransaction({
    required TransactionModel transaction,
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

    final rpcResult = await _supabase.rpc(
      'reject_lost_damaged_transaction',
      params: {
        'p_company_id': companyId,
        'p_transaction_id': transactionId,
        'p_decision_note': _emptyToNull(decisionNote),
      },
    );

    final savedId = _readTransactionIdFromRpcResult(rpcResult);

    return _getTransactionById(
      transactionId: savedId,
      companyId: companyId,
      selectColumns: selectColumns,
    );
  }

  Future<TransactionModel> settleApprovedLostDamagedTransaction({
    required TransactionModel transaction,
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

    final rpcResult = await _supabase.rpc(
      'settle_lost_damaged_transaction',
      params: {
        'p_company_id': companyId,
        'p_transaction_id': transactionId,
        'p_settlement_note': _emptyToNull(settlementNote),
      },
    );

    final savedId = _readTransactionIdFromRpcResult(rpcResult);

    return _getTransactionById(
      transactionId: savedId,
      companyId: companyId,
      selectColumns: selectColumns,
    );
  }

  Future<TransactionModel> _getTransactionById({
    required String transactionId,
    required String companyId,
    required String selectColumns,
  }) async {
    final data = await _supabase
        .from('transactions')
        .select(selectColumns)
        .eq('id', transactionId)
        .eq('company_id', companyId)
        .single();

    return TransactionModel.fromJson(data);
  }

  String _readTransactionIdFromRpcResult(dynamic rpcResult) {
    if (rpcResult is String && rpcResult.trim().isNotEmpty) {
      return rpcResult.trim();
    }

    if (rpcResult is List && rpcResult.isNotEmpty) {
      final firstItem = rpcResult.first;

      if (firstItem is Map<String, dynamic>) {
        final id = firstItem['transaction_id'] as String?;

        if (id != null && id.trim().isNotEmpty) {
          return id.trim();
        }
      }
    }

    if (rpcResult is Map<String, dynamic>) {
      final id = rpcResult['transaction_id'] as String?;

      if (id != null && id.trim().isNotEmpty) {
        return id.trim();
      }
    }

    throw StateError('Transaction ID was not returned by the RPC.');
  }

  String? _emptyToNull(String? value) {
    final clean = value?.trim();

    if (clean == null || clean.isEmpty) {
      return null;
    }

    return clean;
  }
}
