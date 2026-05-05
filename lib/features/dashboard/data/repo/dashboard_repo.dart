import 'package:mina_system/features/dashboard/data/models/dashboard_summary_model.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/data/repo/transactions_repo.dart';
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
    final balances = <String, double>{};

    for (final transaction in transactions) {
      final key = '${transaction.workerHrCode}__${transaction.toolCode}';
      final currentBalance = balances[key] ?? 0;

      if (transaction.isIssue) {
        balances[key] = currentBalance + transaction.quantity;
      } else {
        balances[key] = currentBalance - transaction.quantity;
      }
    }

    return balances.values.where((balance) => balance > 0).length;
  }

  int _calculateClosedToday(List<TransactionModel> transactions) {
    final now = DateTime.now();

    return transactions.where((transaction) {
      final date = transaction.dateTime.toLocal();

      final isToday =
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;

      return isToday && transaction.isClosingTransaction;
    }).length;
  }
}
