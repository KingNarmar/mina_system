part of 'transactions_cubit.dart';

extension TransactionsCubitCrud on TransactionsCubit {
  Future<bool> addTransaction(
    TransactionModel transaction, {
    String? companyId,
    String? createdByProfileId,
  }) async {
    if (companyId == null || companyId.isEmpty) {
      emitState(state.copyWith(errorMessage: 'Company ID was not found'));
      return false;
    }

    if (createdByProfileId == null || createdByProfileId.isEmpty) {
      emitState(state.copyWith(errorMessage: 'Profile ID was not found'));
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
      final transactionCode = await _transactionsRepo
          .generateNextTransactionCode(companyId: companyId);

      final transactionToInsert = TransactionsCubitHelpers.applyApprovalRules(
        transaction.copyWith(
          companyId: companyId,
          transactionCode: transactionCode,
          createdByProfileId: createdByProfileId,
        ),
      );

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
        state.copyWith(isSubmitting: false, errorMessage: error.toString()),
      );
      return false;
    }
  }

  Future<bool> updateTransaction({
    required TransactionModel updatedTransaction,
    String? companyId,
  }) async {
    if (companyId == null || companyId.isEmpty) {
      emitState(state.copyWith(errorMessage: 'Company ID was not found'));
      return false;
    }

    final validationError =
        TransactionsCubitValidators.validateUpdateTransaction(
          updatedTransaction,
        );
    if (validationError != null) {
      emitState(state.copyWith(errorMessage: validationError));
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

    emitState(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final transactionToUpdate = TransactionsCubitHelpers.applyApprovalRules(
        updatedTransaction.copyWith(companyId: companyId),
      );

      final savedTransaction = await _transactionsRepo.updateTransaction(
        transactionId: updatedTransaction.id!,
        transaction: transactionToUpdate,
      );

      _emitReplacedTransaction(savedTransaction, isSubmitting: false);

      return true;
    } catch (error) {
      emitState(
        state.copyWith(isSubmitting: false, errorMessage: error.toString()),
      );
      return false;
    }
  }
}
