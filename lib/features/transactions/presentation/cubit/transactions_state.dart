import 'package:mina_system/features/transactions/data/models/transaction_model.dart';

enum TransactionTypeFilter {
  all,
  issue,
  returnTool,
  lost,
  damaged,
}

class TransactionsState {
  const TransactionsState({
    required this.transactions,
    required this.filteredTransactions,
    required this.searchQuery,
    required this.custodyBalanceSearchQuery,
    required this.toolSummarySearchQuery,
    required this.typeFilter,
  });

  final List<TransactionModel> transactions;
  final List<TransactionModel> filteredTransactions;
  final String searchQuery;
  final String custodyBalanceSearchQuery;
  final String toolSummarySearchQuery;
  final TransactionTypeFilter typeFilter;

  TransactionsState copyWith({
    List<TransactionModel>? transactions,
    List<TransactionModel>? filteredTransactions,
    String? searchQuery,
    String? custodyBalanceSearchQuery,
    String? toolSummarySearchQuery,
    TransactionTypeFilter? typeFilter,
  }) {
    return TransactionsState(
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      searchQuery: searchQuery ?? this.searchQuery,
      custodyBalanceSearchQuery:
          custodyBalanceSearchQuery ?? this.custodyBalanceSearchQuery,
      toolSummarySearchQuery:
          toolSummarySearchQuery ?? this.toolSummarySearchQuery,
      typeFilter: typeFilter ?? this.typeFilter,
    );
  }
}