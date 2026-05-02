import 'package:mina_system/features/transactions/data/models/transaction_model.dart';

class TransactionsState {
  const TransactionsState({
    required this.transactions,
    required this.filteredTransactions,
    required this.searchQuery,
    required this.custodyBalanceSearchQuery,
  });

  final List<TransactionModel> transactions;
  final List<TransactionModel> filteredTransactions;
  final String searchQuery;
  final String custodyBalanceSearchQuery;

  TransactionsState copyWith({
    List<TransactionModel>? transactions,
    List<TransactionModel>? filteredTransactions,
    String? searchQuery,
    String? custodyBalanceSearchQuery,
  }) {
    return TransactionsState(
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      searchQuery: searchQuery ?? this.searchQuery,
      custodyBalanceSearchQuery:
          custodyBalanceSearchQuery ?? this.custodyBalanceSearchQuery,
    );
  }
}