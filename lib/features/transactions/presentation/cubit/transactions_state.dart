import 'package:mina_system/features/transactions/data/models/transaction_model.dart';

enum TransactionTypeFilter { all, issue, returnTool, lost, damaged }

class TransactionsSubmissionKeys {
  const TransactionsSubmissionKeys._();

  static const String add = 'transactions:add';

  static String uploadApprovalDocument(TransactionModel transaction) {
    return _transactionActionKey(
      action: 'upload-approval-document',
      transaction: transaction,
    );
  }

  static String approve(TransactionModel transaction) {
    return _transactionActionKey(action: 'approve', transaction: transaction);
  }

  static String reject(TransactionModel transaction) {
    return _transactionActionKey(action: 'reject', transaction: transaction);
  }

  static String settle(TransactionModel transaction) {
    return _transactionActionKey(action: 'settle', transaction: transaction);
  }

  static String _transactionActionKey({
    required String action,
    required TransactionModel transaction,
  }) {
    return 'transactions:$action:${_transactionKey(transaction)}';
  }

  static String _transactionKey(TransactionModel transaction) {
    final transactionId = transaction.id?.trim();

    if (transactionId != null && transactionId.isNotEmpty) {
      return transactionId;
    }

    final transactionCode = transaction.transactionCode.trim();

    if (transactionCode.isNotEmpty) {
      return transactionCode;
    }

    return [
      transaction.workerHrCode.trim(),
      transaction.toolCode.trim(),
      transaction.dateTime.toIso8601String(),
    ].where((value) => value.isNotEmpty).join(':');
  }
}

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
    this.submittingActionKey,
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
  final String? submittingActionKey;
  final bool isTransactionFormOpen;
  final String? errorMessage;

  bool isActionSubmitting(String actionKey) {
    return isSubmitting && submittingActionKey == actionKey;
  }

  TransactionsState copyWith({
    List<TransactionModel>? transactions,
    List<TransactionModel>? filteredTransactions,
    String? searchQuery,
    String? custodyBalanceSearchQuery,
    String? toolSummarySearchQuery,
    TransactionTypeFilter? typeFilter,
    bool? isLoading,
    bool? isSubmitting,
    String? submittingActionKey,
    bool? isTransactionFormOpen,
    String? errorMessage,
    bool clearSubmittingActionKey = false,
    bool clearErrorMessage = false,
  }) {
    final nextIsSubmitting = isSubmitting ?? this.isSubmitting;

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
      isSubmitting: nextIsSubmitting,
      submittingActionKey: clearSubmittingActionKey || !nextIsSubmitting
          ? null
          : submittingActionKey ?? this.submittingActionKey,
      isTransactionFormOpen:
          isTransactionFormOpen ?? this.isTransactionFormOpen,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
