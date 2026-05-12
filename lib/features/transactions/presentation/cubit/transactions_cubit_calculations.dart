part of 'transactions_cubit.dart';

extension TransactionsCubitCalculations on TransactionsCubit {
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
}
