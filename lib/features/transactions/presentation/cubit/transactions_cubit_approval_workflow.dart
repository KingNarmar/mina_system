part of 'transactions_cubit.dart';

extension TransactionsCubitApprovalWorkflow on TransactionsCubit {
  Future<bool> uploadApprovalDocument({
    required TransactionModel transaction,
    required String localDocumentPath,
  }) async {
    final validationError =
        TransactionsCubitValidators.validateLostDamagedPendingTransaction(
          transaction,
        );
    if (validationError != null) {
      emitState(state.copyWith(errorMessage: validationError));
      return false;
    }

    if (localDocumentPath.trim().isEmpty) {
      emitState(
        state.copyWith(errorMessage: 'Approval document path was not found'),
      );
      return false;
    }

    emitState(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final savedTransaction = await _transactionsRepo.uploadApprovalDocument(
        transaction: transaction,
        localDocumentPath: localDocumentPath,
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

  Future<bool> approveTransaction({
    required TransactionModel transaction,
    required String decidedByProfileId,
    String? decisionNote,
  }) async {
    final validationError =
        TransactionsCubitValidators.validateLostDamagedPendingTransaction(
          transaction,
        );
    if (validationError != null) {
      emitState(state.copyWith(errorMessage: validationError));
      return false;
    }

    final profileError = TransactionsCubitValidators.validateProfileId(
      decidedByProfileId,
    );
    if (profileError != null) {
      emitState(state.copyWith(errorMessage: profileError));
      return false;
    }

    if (!TransactionsCubitValidators.hasApprovalDocument(transaction)) {
      emitState(
        state.copyWith(
          errorMessage:
              'Signed approval document must be uploaded before approval',
        ),
      );
      return false;
    }

    emitState(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final savedTransaction = await _transactionsRepo
          .approveLostDamagedTransaction(
            transaction: transaction,
            decidedByProfileId: decidedByProfileId,
            decisionNote: decisionNote,
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

  Future<bool> rejectTransaction({
    required TransactionModel transaction,
    required String decidedByProfileId,
    String? decisionNote,
  }) async {
    final validationError =
        TransactionsCubitValidators.validateLostDamagedPendingTransaction(
          transaction,
        );
    if (validationError != null) {
      emitState(state.copyWith(errorMessage: validationError));
      return false;
    }

    final profileError = TransactionsCubitValidators.validateProfileId(
      decidedByProfileId,
    );
    if (profileError != null) {
      emitState(state.copyWith(errorMessage: profileError));
      return false;
    }

    if (!TransactionsCubitValidators.hasApprovalDocument(transaction)) {
      emitState(
        state.copyWith(
          errorMessage:
              'Signed approval document must be uploaded before rejection',
        ),
      );
      return false;
    }

    emitState(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final savedTransaction = await _transactionsRepo
          .rejectLostDamagedTransaction(
            transaction: transaction,
            decidedByProfileId: decidedByProfileId,
            decisionNote: decisionNote,
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

  Future<bool> settleTransaction({
    required TransactionModel transaction,
    required String settledByProfileId,
    String? settlementNote,
  }) async {
    final transactionId = transaction.id;

    if (transactionId == null || transactionId.trim().isEmpty) {
      emitState(state.copyWith(errorMessage: 'Transaction ID was not found'));
      return false;
    }

    if (!transaction.isLostOrDamaged) {
      emitState(
        state.copyWith(
          errorMessage: 'Only lost or damaged transactions can be settled',
        ),
      );
      return false;
    }

    if (!transaction.isApprovalApproved) {
      emitState(
        state.copyWith(
          errorMessage:
              'Only approved lost or damaged transactions can be settled',
        ),
      );
      return false;
    }

    if (!transaction.isPendingSettlement) {
      emitState(
        state.copyWith(
          errorMessage: 'Only transactions pending settlement can be settled',
        ),
      );
      return false;
    }

    final profileError = TransactionsCubitValidators.validateProfileId(
      settledByProfileId,
    );
    if (profileError != null) {
      emitState(state.copyWith(errorMessage: profileError));
      return false;
    }

    emitState(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final savedTransaction = await _transactionsRepo
          .settleApprovedLostDamagedTransaction(
            transaction: transaction,
            settledByProfileId: settledByProfileId,
            settlementNote: settlementNote,
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
