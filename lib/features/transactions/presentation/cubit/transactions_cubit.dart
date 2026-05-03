import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/transactions/data/models/custody_balance_model.dart';
import 'package:mina_system/features/transactions/data/models/tool_custody_summary_model.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_state.dart';
import 'package:mina_system/features/transactions/presentation/functions/custody_balance_calculator.dart';
import 'package:mina_system/features/transactions/presentation/functions/tool_summary_calculator.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_code_generator.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_filters.dart';

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
    final filteredTransactions = filterTransactions(
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
    final filteredTransactions = filterTransactions(
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
    return filterCustodyBalances(balances, state.custodyBalanceSearchQuery);
  }

  void searchToolSummaries(String query) {
    emit(state.copyWith(toolSummarySearchQuery: query));
  }

  List<ToolCustodySummaryModel> getFilteredToolCustodySummaries() {
    final summaries = getToolCustodySummaries();
    return filterToolCustodySummaries(summaries, state.toolSummarySearchQuery);
  }

  void addTransaction(TransactionModel transaction) {
    final updatedTransactions = List<TransactionModel>.from(state.transactions)
      ..insert(0, transaction);

    emitUpdatedTransactions(updatedTransactions);
  }

  String generateNextTransactionCode() {
    return generateNextTransactionCodeFromList(state.transactions);
  }

  double getWorkerToolBalance({
    required String workerHrCode,
    required String toolCode,
  }) {
    return calculateWorkerToolBalance(
      transactions: state.transactions,
      workerHrCode: workerHrCode,
      toolCode: toolCode,
    );
  }

  bool hasWorkerTransactions(String workerHrCode) {
    return checkHasWorkerTransactions(state.transactions, workerHrCode);
  }

  bool hasToolTransactions(String toolCode) {
    return checkHasToolTransactions(state.transactions, toolCode);
  }

  List<CustodyBalanceModel> getCustodyBalances() {
    return calculateCustodyBalances(state.transactions);
  }

  List<ToolCustodySummaryModel> getToolCustodySummaries() {
    return calculateToolCustodySummaries(state.transactions);
  }

  int getClosedTodayCount() {
    return calculateClosedTodayCount(state.transactions);
  }

  void emitUpdatedTransactions(List<TransactionModel> transactions) {
    emit(
      state.copyWith(
        transactions: transactions,
        filteredTransactions: filterTransactions(
          transactions: transactions,
          query: state.searchQuery,
          typeFilter: state.typeFilter,
        ),
      ),
    );
  }
}
