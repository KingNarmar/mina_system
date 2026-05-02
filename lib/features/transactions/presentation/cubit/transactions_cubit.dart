import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_state.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  TransactionsCubit()
    : super(
        const TransactionsState(
          transactions: [],
          filteredTransactions: [],
          searchQuery: '',
        ),
      );

  void searchTransactions(String query) {
    final filteredTransactions = _filterTransactions(
      transactions: state.transactions,
      query: query,
    );

    emit(
      state.copyWith(
        searchQuery: query,
        filteredTransactions: filteredTransactions,
      ),
    );
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
      } else {
        balance -= transaction.quantity;
      }
    }

    return balance < 0 ? 0 : balance;
  }

  int getReturnedTodayCount() {
    final now = DateTime.now();

    return state.transactions.where((transaction) {
      final isSameYear = transaction.dateTime.year == now.year;
      final isSameMonth = transaction.dateTime.month == now.month;
      final isSameDay = transaction.dateTime.day == now.day;

      return transaction.isReturn && isSameYear && isSameMonth && isSameDay;
    }).length;
  }

  void emitUpdatedTransactions(List<TransactionModel> transactions) {
    emit(
      state.copyWith(
        transactions: transactions,
        filteredTransactions: _filterTransactions(
          transactions: transactions,
          query: state.searchQuery,
        ),
      ),
    );
  }

  List<TransactionModel> _filterTransactions({
    required List<TransactionModel> transactions,
    required String query,
  }) {
    final searchQuery = _normalizeText(query);

    if (searchQuery.isEmpty) {
      return transactions;
    }

    return transactions.where((transaction) {
      final transactionCode = _normalizeText(transaction.transactionCode);
      final workerHrCode = _normalizeText(transaction.workerHrCode);
      final workerName = _normalizeText(transaction.workerName);
      final toolCode = _normalizeText(transaction.toolCode);
      final toolName = _normalizeText(transaction.toolName);
      final unit = _normalizeText(transaction.unit);
      final type = transaction.isIssue ? 'issue' : 'return';

      return transactionCode.contains(searchQuery) ||
          workerHrCode.contains(searchQuery) ||
          workerName.contains(searchQuery) ||
          toolCode.contains(searchQuery) ||
          toolName.contains(searchQuery) ||
          unit.contains(searchQuery) ||
          type.contains(searchQuery);
    }).toList();
  }

  String _normalizeText(String value) {
    return value.trim().toLowerCase();
  }
}
