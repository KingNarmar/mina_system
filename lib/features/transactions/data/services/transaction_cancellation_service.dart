import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionCancellationService {
  TransactionCancellationService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<void> cancelTransaction({
    required String companyId,
    required String transactionId,
    required String reason,
  }) async {
    final cleanCompanyId = companyId.trim();
    final cleanTransactionId = transactionId.trim();
    final cleanReason = reason.trim();

    if (cleanCompanyId.isEmpty) {
      throw StateError('Company ID was not found.');
    }

    if (cleanTransactionId.isEmpty) {
      throw StateError('Transaction ID was not found.');
    }

    if (cleanReason.isEmpty) {
      throw StateError('Cancellation reason is required.');
    }

    await _supabase.rpc(
      'void_transaction',
      params: {
        'p_company_id': cleanCompanyId,
        'p_transaction_id': cleanTransactionId,
        'p_void_reason': cleanReason,
      },
    );
  }
}
