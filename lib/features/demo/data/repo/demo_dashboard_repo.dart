import 'package:mina_system/features/dashboard/data/models/dashboard_summary_model.dart';
import 'package:mina_system/features/dashboard/data/repo/dashboard_repo.dart';
import 'package:mina_system/features/demo/data/services/demo_local_storage_service.dart';
import 'package:mina_system/features/demo/data/services/demo_storage_keys.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/custody_balance_calculator.dart';

class DemoDashboardRepo extends DashboardRepo {
  DemoDashboardRepo({
    DemoLocalStorageService storage = const DemoLocalStorageService(),
  }) : _storage = storage;

  final DemoLocalStorageService _storage;

  @override
  Future<DashboardSummaryModel> getDashboardSummary({
    required String companyId,
  }) async {
    final workersData = await _storage.readJsonList(DemoStorageKeys.workers);
    final toolsData = await _storage.readJsonList(DemoStorageKeys.tools);
    final transactionsData = await _storage.readJsonList(
      DemoStorageKeys.transactions,
    );

    final transactions = transactionsData
        .map(TransactionModel.fromJson)
        .where((transaction) => transaction.companyId == companyId)
        .toList();

    transactions.sort((first, second) {
      return second.dateTime.compareTo(first.dateTime);
    });

    return DashboardSummaryModel(
      totalWorkers: _countActiveCompanyRecords(
        records: workersData,
        companyId: companyId,
      ),
      totalTools: _countActiveCompanyRecords(
        records: toolsData,
        companyId: companyId,
      ),
      openCustodies: _calculateOpenCustodies(transactions),
      closedToday: _calculateClosedToday(transactions),
      recentTransactions: transactions.take(5).toList(growable: false),
    );
  }

  int _countActiveCompanyRecords({
    required List<Map<String, dynamic>> records,
    required String companyId,
  }) {
    return records.where((record) {
      final recordCompanyId = record['company_id'] as String?;
      final status = record['status'] as String? ?? 'active';

      return recordCompanyId == companyId && status == 'active';
    }).length;
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
