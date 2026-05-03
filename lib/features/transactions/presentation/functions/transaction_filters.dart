import 'package:mina_system/features/transactions/data/models/custody_balance_model.dart';
import 'package:mina_system/features/transactions/data/models/tool_custody_summary_model.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_state.dart';

String normalizeText(String value) {
  return value.trim().toLowerCase();
}

String getTransactionTypeLabel(TransactionModel transaction) {
  if (transaction.isIssue) return 'issue';
  if (transaction.isReturn) return 'return';
  if (transaction.isLost) return 'lost';
  if (transaction.isDamaged) return 'damaged';
  return '';
}

bool matchesTransactionType(
  TransactionModel transaction,
  TransactionTypeFilter typeFilter,
) {
  switch (typeFilter) {
    case TransactionTypeFilter.all:
      return true;
    case TransactionTypeFilter.issue:
      return transaction.isIssue;
    case TransactionTypeFilter.returnTool:
      return transaction.isReturn;
    case TransactionTypeFilter.lost:
      return transaction.isLost;
    case TransactionTypeFilter.damaged:
      return transaction.isDamaged;
  }
}

List<TransactionModel> filterTransactions({
  required List<TransactionModel> transactions,
  required String query,
  required TransactionTypeFilter typeFilter,
}) {
  final searchQuery = normalizeText(query);

  return transactions.where((transaction) {
    final matchesType = matchesTransactionType(transaction, typeFilter);

    if (!matchesType) {
      return false;
    }

    if (searchQuery.isEmpty) {
      return true;
    }

    final transactionCode = normalizeText(transaction.transactionCode);
    final workerHrCode = normalizeText(transaction.workerHrCode);
    final workerName = normalizeText(transaction.workerName);
    final toolCode = normalizeText(transaction.toolCode);
    final toolName = normalizeText(transaction.toolName);
    final unit = normalizeText(transaction.unit);
    final type = getTransactionTypeLabel(transaction);

    return transactionCode.contains(searchQuery) ||
        workerHrCode.contains(searchQuery) ||
        workerName.contains(searchQuery) ||
        toolCode.contains(searchQuery) ||
        toolName.contains(searchQuery) ||
        unit.contains(searchQuery) ||
        type.contains(searchQuery);
  }).toList();
}

List<CustodyBalanceModel> filterCustodyBalances(
  List<CustodyBalanceModel> balances,
  String query,
) {
  final searchQuery = normalizeText(query);

  if (searchQuery.isEmpty) {
    return balances;
  }

  return balances.where((balance) {
    final workerHrCode = normalizeText(balance.workerHrCode);
    final workerName = normalizeText(balance.workerName);
    final toolCode = normalizeText(balance.toolCode);
    final toolName = normalizeText(balance.toolName);
    final unit = normalizeText(balance.unit);

    return workerHrCode.contains(searchQuery) ||
        workerName.contains(searchQuery) ||
        toolCode.contains(searchQuery) ||
        toolName.contains(searchQuery) ||
        unit.contains(searchQuery);
  }).toList();
}

List<ToolCustodySummaryModel> filterToolCustodySummaries(
  List<ToolCustodySummaryModel> summaries,
  String query,
) {
  final searchQuery = normalizeText(query);

  if (searchQuery.isEmpty) {
    return summaries;
  }

  return summaries.where((summary) {
    final toolCode = normalizeText(summary.toolCode);
    final toolName = normalizeText(summary.toolName);
    final unit = normalizeText(summary.unit);

    return toolCode.contains(searchQuery) ||
        toolName.contains(searchQuery) ||
        unit.contains(searchQuery);
  }).toList();
}
