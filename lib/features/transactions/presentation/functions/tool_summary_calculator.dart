import 'package:mina_system/features/transactions/data/models/tool_custody_summary_model.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/custody_balance_calculator.dart';

List<ToolCustodySummaryModel> calculateToolCustodySummaries(
  List<TransactionModel> transactions,
) {
  final summariesMap = <String, ToolCustodySummaryModel>{};

  for (final transaction in transactions) {
    final key = transaction.toolCode;
    final currentSummary = summariesMap[key];

    final summary =
        currentSummary ??
        ToolCustodySummaryModel(
          toolCode: transaction.toolCode,
          toolName: transaction.toolName,
          unit: transaction.unit,
          issuedQuantity: 0,
          returnedQuantity: 0,
          lostQuantity: 0,
          damagedQuantity: 0,
          openCustodyQuantity: 0,
          totalMovements: 0,
        );

    summariesMap[key] = summary.copyWith(
      issuedQuantity: transaction.isIssue
          ? summary.issuedQuantity + transaction.quantity
          : summary.issuedQuantity,
      returnedQuantity: transaction.isReturn
          ? summary.returnedQuantity + transaction.quantity
          : summary.returnedQuantity,
      lostQuantity: transaction.isLost
          ? summary.lostQuantity + transaction.quantity
          : summary.lostQuantity,
      damagedQuantity: transaction.isDamaged
          ? summary.damagedQuantity + transaction.quantity
          : summary.damagedQuantity,
      openCustodyQuantity: transaction.isIssue
          ? summary.openCustodyQuantity + transaction.quantity
          : shouldReduceCustodyBalance(transaction)
          ? summary.openCustodyQuantity - transaction.quantity
          : summary.openCustodyQuantity,
      totalMovements: summary.totalMovements + 1,
    );
  }

  final summaries = summariesMap.values.map((summary) {
    return summary.copyWith(
      openCustodyQuantity: summary.openCustodyQuantity < 0
          ? 0
          : summary.openCustodyQuantity,
    );
  }).toList();

  summaries.sort((first, second) {
    return first.toolName.compareTo(second.toolName);
  });

  return summaries;
}

int calculateClosedTodayCount(List<TransactionModel> transactions) {
  final now = DateTime.now();

  return transactions.where((transaction) {
    final isSameYear = transaction.dateTime.year == now.year;
    final isSameMonth = transaction.dateTime.month == now.month;
    final isSameDay = transaction.dateTime.day == now.day;

    return shouldReduceCustodyBalance(transaction) &&
        isSameYear &&
        isSameMonth &&
        isSameDay;
  }).length;
}
