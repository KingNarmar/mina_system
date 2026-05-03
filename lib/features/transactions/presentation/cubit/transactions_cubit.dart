import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/transactions/data/models/custody_balance_model.dart';
import 'package:mina_system/features/transactions/data/models/tool_custody_summary_model.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_state.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  TransactionsCubit()
    : super(
        const TransactionsState(
          transactions: [],
          filteredTransactions: [],
          searchQuery: '',
          custodyBalanceSearchQuery: '',
          toolSummarySearchQuery: '',
          typeFilter: TransactionTypeFilter.all,
        ),
      );

  void searchTransactions(String query) {
    final filteredTransactions = _filterTransactions(
      transactions: state.transactions,
      query: query,
      typeFilter: state.typeFilter,
    );

    emit(
      state.copyWith(
        searchQuery: query,
        filteredTransactions: filteredTransactions,
      ),
    );
  }

  void filterTransactionsByType(TransactionTypeFilter typeFilter) {
    final filteredTransactions = _filterTransactions(
      transactions: state.transactions,
      query: state.searchQuery,
      typeFilter: typeFilter,
    );

    emit(
      state.copyWith(
        typeFilter: typeFilter,
        filteredTransactions: filteredTransactions,
      ),
    );
  }

  void searchCustodyBalances(String query) {
    emit(state.copyWith(custodyBalanceSearchQuery: query));
  }

  List<CustodyBalanceModel> getFilteredCustodyBalances() {
    final balances = getCustodyBalances();
    final searchQuery = _normalizeText(state.custodyBalanceSearchQuery);

    if (searchQuery.isEmpty) {
      return balances;
    }

    return balances.where((balance) {
      final workerHrCode = _normalizeText(balance.workerHrCode);
      final workerName = _normalizeText(balance.workerName);
      final toolCode = _normalizeText(balance.toolCode);
      final toolName = _normalizeText(balance.toolName);
      final unit = _normalizeText(balance.unit);

      return workerHrCode.contains(searchQuery) ||
          workerName.contains(searchQuery) ||
          toolCode.contains(searchQuery) ||
          toolName.contains(searchQuery) ||
          unit.contains(searchQuery);
    }).toList();
  }

  void searchToolSummaries(String query) {
    emit(state.copyWith(toolSummarySearchQuery: query));
  }

  List<ToolCustodySummaryModel> getFilteredToolCustodySummaries() {
    final summaries = getToolCustodySummaries();
    final searchQuery = _normalizeText(state.toolSummarySearchQuery);

    if (searchQuery.isEmpty) {
      return summaries;
    }

    return summaries.where((summary) {
      final toolCode = _normalizeText(summary.toolCode);
      final toolName = _normalizeText(summary.toolName);
      final unit = _normalizeText(summary.unit);

      return toolCode.contains(searchQuery) ||
          toolName.contains(searchQuery) ||
          unit.contains(searchQuery);
    }).toList();
  }

  void addTransaction(TransactionModel transaction) {
    final updatedTransactions = List<TransactionModel>.from(state.transactions)
      ..insert(0, transaction);

    emitUpdatedTransactions(updatedTransactions);
  }

  String generateNextTransactionCode() {
    const prefix = 'TRX-';
    var maxNumber = 0;

    for (final transaction in state.transactions) {
      final transactionCode = transaction.transactionCode.trim().toUpperCase();

      if (!transactionCode.startsWith(prefix)) {
        continue;
      }

      final numberPart = transactionCode.substring(prefix.length);
      final number = int.tryParse(numberPart);

      if (number != null && number > maxNumber) {
        maxNumber = number;
      }
    }

    final nextNumber = maxNumber + 1;

    return '$prefix${nextNumber.toString().padLeft(3, '0')}';
  }

  double getWorkerToolBalance({
    required String workerHrCode,
    required String toolCode,
  }) {
    var balance = 0.0;

    for (final transaction in state.transactions) {
      final isSameWorker =
          _normalizeText(transaction.workerHrCode) ==
          _normalizeText(workerHrCode);

      final isSameTool =
          _normalizeText(transaction.toolCode) == _normalizeText(toolCode);

      if (!isSameWorker || !isSameTool) {
        continue;
      }

      if (transaction.isIssue) {
        balance += transaction.quantity;
      } else if (transaction.isClosingTransaction) {
        balance -= transaction.quantity;
      }
    }

    return balance < 0 ? 0 : balance;
  }

  bool hasWorkerTransactions(String workerHrCode) {
    final normalizedWorkerHrCode = _normalizeText(workerHrCode);

    return state.transactions.any((transaction) {
      return _normalizeText(transaction.workerHrCode) == normalizedWorkerHrCode;
    });
  }

  bool hasToolTransactions(String toolCode) {
    final normalizedToolCode = _normalizeText(toolCode);

    return state.transactions.any((transaction) {
      return _normalizeText(transaction.toolCode) == normalizedToolCode;
    });
  }

  List<CustodyBalanceModel> getCustodyBalances() {
    final balancesMap = <String, CustodyBalanceModel>{};

    for (final transaction in state.transactions) {
      final key = '${transaction.workerHrCode}_${transaction.toolCode}';

      final currentBalance = balancesMap[key];

      final quantityChange = transaction.isIssue
          ? transaction.quantity
          : -transaction.quantity;

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

  List<ToolCustodySummaryModel> getToolCustodySummaries() {
    final summariesMap = <String, ToolCustodySummaryModel>{};

    for (final transaction in state.transactions) {
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
            : summary.openCustodyQuantity - transaction.quantity,
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

  int getClosedTodayCount() {
    final now = DateTime.now();

    return state.transactions.where((transaction) {
      final isSameYear = transaction.dateTime.year == now.year;
      final isSameMonth = transaction.dateTime.month == now.month;
      final isSameDay = transaction.dateTime.day == now.day;

      return transaction.isClosingTransaction &&
          isSameYear &&
          isSameMonth &&
          isSameDay;
    }).length;
  }

  void emitUpdatedTransactions(List<TransactionModel> transactions) {
    emit(
      state.copyWith(
        transactions: transactions,
        filteredTransactions: _filterTransactions(
          transactions: transactions,
          query: state.searchQuery,
          typeFilter: state.typeFilter,
        ),
      ),
    );
  }

  List<TransactionModel> _filterTransactions({
    required List<TransactionModel> transactions,
    required String query,
    required TransactionTypeFilter typeFilter,
  }) {
    final searchQuery = _normalizeText(query);

    return transactions.where((transaction) {
      final matchesType = _matchesTransactionType(transaction, typeFilter);

      if (!matchesType) {
        return false;
      }

      if (searchQuery.isEmpty) {
        return true;
      }

      final transactionCode = _normalizeText(transaction.transactionCode);
      final workerHrCode = _normalizeText(transaction.workerHrCode);
      final workerName = _normalizeText(transaction.workerName);
      final toolCode = _normalizeText(transaction.toolCode);
      final toolName = _normalizeText(transaction.toolName);
      final unit = _normalizeText(transaction.unit);
      final type = _getTransactionTypeLabel(transaction);

      return transactionCode.contains(searchQuery) ||
          workerHrCode.contains(searchQuery) ||
          workerName.contains(searchQuery) ||
          toolCode.contains(searchQuery) ||
          toolName.contains(searchQuery) ||
          unit.contains(searchQuery) ||
          type.contains(searchQuery);
    }).toList();
  }

  bool _matchesTransactionType(
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

  String _getTransactionTypeLabel(TransactionModel transaction) {
    if (transaction.isIssue) {
      return 'issue';
    }

    if (transaction.isReturn) {
      return 'return';
    }

    if (transaction.isLost) {
      return 'lost';
    }

    if (transaction.isDamaged) {
      return 'damaged';
    }

    return '';
  }

  String _normalizeText(String value) {
    return value.trim().toLowerCase();
  }
}
