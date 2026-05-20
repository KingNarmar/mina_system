import 'package:mina_system/features/transactions/data/models/transaction_model.dart';

enum TransactionTypeFilter { all, issue, returnTool, lost, damaged }

class TransactionsState {
  const TransactionsState({
    required this.transactions,
    required this.filteredTransactions,
    required this.searchQuery,
    required this.custodyBalanceSearchQuery,
    required this.toolSummarySearchQuery,
    required this.typeFilter,
    this.isLoading = false,
    this.isSubmitting = false,
    this.isTransactionFormOpen = false,
    this.errorMessage,
  });

  final List<TransactionModel> transactions;
  final List<TransactionModel> filteredTransactions;
  final String searchQuery;
  final String custodyBalanceSearchQuery;
  final String toolSummarySearchQuery;
  final TransactionTypeFilter typeFilter;
  final bool isLoading;
  final bool isSubmitting;
  final bool isTransactionFormOpen;
  final String? errorMessage;

  TransactionsState copyWith({
    List<TransactionModel>? transactions,
    List<TransactionModel>? filteredTransactions,
    String? searchQuery,
    String? custodyBalanceSearchQuery,
    String? toolSummarySearchQuery,
    TransactionTypeFilter? typeFilter,
    bool? isLoading,
    bool? isSubmitting,
    bool? isTransactionFormOpen,
    String? errorMessage,
    bool clearErrorMessage = false,
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
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isTransactionFormOpen:
          isTransactionFormOpen ?? this.isTransactionFormOpen,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
