import 'package:mina_system/features/dashboard/data/models/dashboard_summary_model.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/data/repo/transactions_repo.dart';
import 'package:mina_system/features/transactions/presentation/functions/custody_balance_calculator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardRepo {
  DashboardRepo({
    SupabaseClient? supabaseClient,
    TransactionsRepo? transactionsRepo,
  }) : _supabase = supabaseClient ?? Supabase.instance.client,
       _transactionsRepo = transactionsRepo ?? TransactionsRepo();

  final SupabaseClient _supabase;
  final TransactionsRepo _transactionsRepo;

  Future<DashboardSummaryModel> getDashboardSummary({
    required String companyId,
  }) async {
    final workersData = await _supabase
        .from('workers')
        .select('id')
        .eq('company_id', companyId)
        .eq('status', 'active');

    final toolsData = await _supabase
        .from('tools')
        .select('id')
        .eq('company_id', companyId)
        .eq('status', 'active');

    final transactions = await _transactionsRepo.getTransactions(
      companyId: companyId,
    );

    return DashboardSummaryModel(
      totalWorkers: workersData.length,
      totalTools: toolsData.length,
      openCustodies: _calculateOpenCustodies(transactions),
      closedToday: _calculateClosedToday(transactions),
      recentTransactions: transactions.take(5).toList(),
    );
  }

  int _calculateOpenCustodies(List<TransactionModel> transactions) {
    return calculateCustodyBalances(transactions).length;
  }

  int _calculateClosedToday(List<TransactionModel> transactions) {
    final now = DateTime.now();

    return transactions.where((transaction) {
      final closedDate = _getTransactionClosedDate(transaction);

      if (closedDate == null) {
        return false;
      }

      final localClosedDate = closedDate.toLocal();

      return localClosedDate.year == now.year &&
          localClosedDate.month == now.month &&
          localClosedDate.day == now.day;
    }).length;
  }

  DateTime? _getTransactionClosedDate(TransactionModel transaction) {
    if (transaction.isReturn) {
      return transaction.dateTime;
    }

    if (transaction.isLostOrDamaged &&
        shouldReduceCustodyBalance(transaction)) {
      return transaction.settledAt;
    }

    return null;
  }
}
