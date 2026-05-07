import 'package:mina_system/features/transactions/data/models/custody_balance_model.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_filters.dart';

double calculateWorkerToolBalance({
  required List<TransactionModel> transactions,
  required String workerHrCode,
  required String toolCode,
}) {
  var balance = 0.0;

  for (final transaction in transactions) {
    final isSameWorker =
        normalizeText(transaction.workerHrCode) == normalizeText(workerHrCode);

    final isSameTool =
        normalizeText(transaction.toolCode) == normalizeText(toolCode);

    if (!isSameWorker || !isSameTool) {
      continue;
    }

    if (transaction.isIssue) {
      balance += transaction.quantity;
    } else if (shouldReduceCustodyBalance(transaction)) {
      balance -= transaction.quantity;
    }
  }

  return balance < 0 ? 0 : balance;
}

bool checkHasWorkerTransactions(
  List<TransactionModel> transactions,
  String workerHrCode,
) {
  final normalizedWorkerHrCode = normalizeText(workerHrCode);

  return transactions.any((transaction) {
    return normalizeText(transaction.workerHrCode) == normalizedWorkerHrCode;
  });
}

bool checkHasToolTransactions(
  List<TransactionModel> transactions,
  String toolCode,
) {
  final normalizedToolCode = normalizeText(toolCode);

  return transactions.any((transaction) {
    return normalizeText(transaction.toolCode) == normalizedToolCode;
  });
}

List<CustodyBalanceModel> calculateCustodyBalances(
  List<TransactionModel> transactions,
) {
  final balancesMap = <String, CustodyBalanceModel>{};

  for (final transaction in transactions) {
    final key = '${transaction.workerHrCode}_${transaction.toolCode}';

    final currentBalance = balancesMap[key];

    final quantityChange = transaction.isIssue
        ? transaction.quantity
        : shouldReduceCustodyBalance(transaction)
        ? -transaction.quantity
        : 0.0;

    if (quantityChange == 0) {
      continue;
    }

    if (currentBalance == null) {
      balancesMap[key] = CustodyBalanceModel(
        workerHrCode: transaction.workerHrCode,
        workerName: transaction.workerName,
        toolCode: transaction.toolCode,
        toolName: transaction.toolName,
        unit: transaction.unit,
        balanceQuantity: quantityChange,
      );
      continue;
    }

    balancesMap[key] = CustodyBalanceModel(
      workerHrCode: currentBalance.workerHrCode,
      workerName: currentBalance.workerName,
      toolCode: currentBalance.toolCode,
      toolName: currentBalance.toolName,
      unit: currentBalance.unit,
      balanceQuantity: currentBalance.balanceQuantity + quantityChange,
    );
  }

  final balances = balancesMap.values.where((balance) {
    return balance.balanceQuantity > 0;
  }).toList();

  balances.sort((first, second) {
    return first.workerName.compareTo(second.workerName);
  });

  return balances;
}

bool shouldReduceCustodyBalance(TransactionModel transaction) {
  if (transaction.isReturn) {
    return true;
  }

  if (transaction.isLost || transaction.isDamaged) {
    return _isApproved(transaction.approvalStatus);
  }

  return false;
}

bool _isApproved(String approvalStatus) {
  return approvalStatus.trim().toLowerCase() == 'approved';
}
