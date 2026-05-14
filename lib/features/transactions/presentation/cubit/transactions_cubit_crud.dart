part of 'transactions_cubit.dart';

extension TransactionsCubitCrud on TransactionsCubit {
  Future<bool> addTransaction(
    TransactionModel transaction, {
    String? companyId,
  }) async {
    if (companyId == null || companyId.isEmpty) {
      emitState(state.copyWith(errorMessage: 'Company ID was not found'));
      return false;
    }

    final validationError = TransactionsCubitValidators.validateAddTransaction(
      transaction,
    );
    if (validationError != null) {
      emitState(state.copyWith(errorMessage: validationError));
      return false;
    }

    if (transaction.isClosingTransaction) {
      final currentBalance = getWorkerToolBalance(
        workerHrCode: transaction.workerHrCode,
        toolCode: transaction.toolCode,
      );

      if (transaction.quantity > currentBalance) {
        emitState(
          state.copyWith(
            errorMessage:
                'Quantity cannot be greater than current custody balance',
          ),
        );
        return false;
      }
    }

    try {
      await _networkStatusService.ensureOnline();
    } on NetworkUnavailableException catch (error) {
      emitState(
        state.copyWith(isSubmitting: false, errorMessage: error.message),
      );
      return false;
    }

    emitState(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final transactionToInsert = transaction.copyWith(companyId: companyId);

      final addedTransaction = await _transactionsRepo.addTransaction(
        transaction: transactionToInsert,
      );

      emitUpdatedTransactions([
        addedTransaction,
        ...state.transactions,
      ], isSubmitting: false);

      return true;
    } catch (error, stackTrace) {
      print('ADD TRANSACTION ERROR: $error');
      print('ADD TRANSACTION STACKTRACE: $stackTrace');

      emitState(
        state.copyWith(
          isSubmitting: false,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to save transaction. Please try again.',
          ),
        ),
      );
      return false;
    }
  }

  Future<bool> updateTransaction({
    required TransactionModel updatedTransaction,
    String? companyId,
  }) async {
    emitState(
      state.copyWith(
        isSubmitting: false,
        errorMessage:
            'General transaction editing is not available. Use controlled transaction workflows instead.',
      ),
    );

    return false;
  }
}
