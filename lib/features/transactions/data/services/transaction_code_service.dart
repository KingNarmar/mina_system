import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/transaction_helper_service.dart';

class TransactionCodeService {
  TransactionCodeService({required SupabaseClient supabase})
    : _supabase = supabase;

  final SupabaseClient _supabase;

  Future<String> generateNextTransactionCode({
    required String companyId,
  }) async {
    final data = await _supabase
        .from('transactions')
        .select('transaction_code')
        .eq('company_id', companyId);

    var maxNumber = 0;

    for (final item in data) {
      final transactionCode = item['transaction_code'] as String?;
      final number = TransactionHelperService.extractEndingNumber(
        transactionCode,
      );

      if (number > maxNumber) {
        maxNumber = number;
      }
    }

    final nextNumber = maxNumber + 1;
    return 'TRX-${nextNumber.toString().padLeft(3, '0')}';
  }

  Future<bool> transactionCodeExists({
    required String companyId,
    required String transactionCode,
    String? ignoredTransactionId,
  }) async {
    final cleanTransactionCode = transactionCode.trim();

    if (cleanTransactionCode.isEmpty) {
      return false;
    }

    final data = await _supabase
        .from('transactions')
        .select('id, transaction_code')
        .eq('company_id', companyId);

    return data.any((item) {
      final transactionId = item['id'] as String?;
      final existingTransactionCode = item['transaction_code'] as String?;

      if (ignoredTransactionId != null &&
          transactionId == ignoredTransactionId) {
        return false;
      }

      return TransactionHelperService.isSameTransactionCode(
        existingTransactionCode,
        cleanTransactionCode,
      );
    });
  }
}
