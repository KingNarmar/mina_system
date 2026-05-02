import 'package:mina_system/features/transactions/data/models/transaction_model.dart';

class TransactionsState {
  const TransactionsState({
    required this.transactions,
    required this.filteredTransactions,
    required this.searchQuery,
  });

  final List<TransactionModel> transactions;
  final List<TransactionModel> filteredTransactions;
  final String searchQuery;

  TransactionsState copyWith({
    List<TransactionModel>? transactions,
    List<TransactionModel>? filteredTransactions,
    String? searchQuery,
  }) {
    return TransactionsState(
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}