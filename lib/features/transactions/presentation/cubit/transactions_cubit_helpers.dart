import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_state.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_filters.dart';

class TransactionsCubitHelpers {
  static TransactionModel applyApprovalRules(TransactionModel transaction) {
    if (transaction.isLost || transaction.isDamaged) {
      return transaction.copyWith(
        approvalRequired: true,
        approvalStatus: transaction.approvalStatus == 'not_required'
            ? 'pending'
            : transaction.approvalStatus,
        settlementStatus: transaction.settlementStatus == 'not_required'
            ? 'not_required'
            : transaction.settlementStatus,
      );
    }

    return transaction.copyWith(
      approvalRequired: false,
      approvalStatus: 'not_required',
      settlementStatus: 'not_required',
    );
  }

  static TransactionsState updateTransactionsList(
    TransactionsState state,
    List<TransactionModel> transactions, {
    bool? isLoading,
    bool? isSubmitting,
  }) {
    return state.copyWith(
      transactions: transactions,
      filteredTransactions: filterTransactions(
        transactions: transactions,
        query: state.searchQuery,
        typeFilter: state.typeFilter,
      ),
      isLoading: isLoading,
      isSubmitting: isSubmitting,
      clearErrorMessage: true,
    );
  }

  static List<TransactionModel> replaceTransactionInList(
    List<TransactionModel> transactions,
    TransactionModel savedTransaction,
  ) {
    return transactions.map((transaction) {
      if (transaction.id == savedTransaction.id) {
        return savedTransaction;
      }

      return transaction;
    }).toList();
  }
}
