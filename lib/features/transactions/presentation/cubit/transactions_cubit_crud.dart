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

    emitState(
      state.copyWith(
        isSubmitting: true,
        submittingActionKey: TransactionsSubmissionKeys.add,
        clearErrorMessage: true,
      ),
    );

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
    } catch (error) {
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

  Future<bool> cancelTransaction({
    required TransactionModel transaction,
    required String reason,
    String? companyId,
  }) async {
    final cleanCompanyId = companyId?.trim() ?? transaction.companyId?.trim();
    final transactionId = transaction.id?.trim();
    final cleanReason = reason.trim();

    if (cleanCompanyId == null || cleanCompanyId.isEmpty) {
      emitState(state.copyWith(errorMessage: 'Company ID was not found'));
      return false;
    }

    if (transactionId == null || transactionId.isEmpty) {
      emitState(state.copyWith(errorMessage: 'Transaction ID was not found'));
      return false;
    }

    if (transaction.isVoided) {
      emitState(state.copyWith(errorMessage: 'Transaction is already voided'));
      return false;
    }

    if (cleanReason.isEmpty) {
      emitState(state.copyWith(errorMessage: 'Void reason is required'));
      return false;
    }

    try {
      await _networkStatusService.ensureOnline();
    } on NetworkUnavailableException catch (error) {
      emitState(
        state.copyWith(isSubmitting: false, errorMessage: error.message),
      );
      return false;
    }

    emitState(
      state.copyWith(
        isSubmitting: true,
        submittingActionKey: 'transactions:void:$transactionId',
        clearErrorMessage: true,
      ),
    );

    try {
      await _transactionCancellationService.cancelTransaction(
        companyId: cleanCompanyId,
        transactionId: transactionId,
        reason: cleanReason,
      );

      await loadTransactions(companyId: cleanCompanyId);

      emitState(state.copyWith(isSubmitting: false));
      return true;
    } catch (error) {
      emitState(
        state.copyWith(
          isSubmitting: false,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to void transaction. Please try again.',
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
