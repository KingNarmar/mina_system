part of 'transactions_cubit.dart';

extension TransactionsCubitLoadSearch on TransactionsCubit {
  Future<void> loadTransactions({
    required String companyId,
    bool showLoader = true,
  }) async {
    if (showLoader) {
      emitState(state.copyWith(isLoading: true, clearErrorMessage: true));
    } else {
      emitState(state.copyWith(clearErrorMessage: true));
    }

    try {
      final transactions = await _transactionsRepo.getTransactions(
        companyId: companyId,
      );

      emitUpdatedTransactions(transactions, isLoading: false);
    } catch (error) {
      emitState(
        state.copyWith(
          isLoading: false,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to load transactions. Please try again.',
          ),
        ),
      );
    }
  }

  void searchTransactions(String query) {
    final filteredTransactions = filterTransactions(
      transactions: state.transactions,
      query: query,
      typeFilter: state.typeFilter,
    );

    emitState(
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

    emitState(
      state.copyWith(
        typeFilter: typeFilter,
        filteredTransactions: filteredTransactions,
      ),
    );
  }

  void searchCustodyBalances(String query) {
    emitState(state.copyWith(custodyBalanceSearchQuery: query));
  }

  List<CustodyBalanceModel> getFilteredCustodyBalances() {
    final balances = getCustodyBalances();
    return filterCustodyBalances(balances, state.custodyBalanceSearchQuery);
  }

  void searchToolSummaries(String query) {
    emitState(state.copyWith(toolSummarySearchQuery: query));
  }

  List<ToolCustodySummaryModel> getFilteredToolCustodySummaries() {
    final summaries = getToolCustodySummaries();
    return filterToolCustodySummaries(summaries, state.toolSummarySearchQuery);
  }
}
