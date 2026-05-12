import 'package:mina_system/features/transactions/data/models/transaction_model.dart';

class TransactionsCubitValidators {
  static String? validateAddTransaction(TransactionModel transaction) {
    if (transaction.workerId == null || transaction.workerId!.isEmpty) {
      return 'Worker ID was not found';
    }

    if (transaction.toolId == null || transaction.toolId!.isEmpty) {
      return 'Tool ID was not found';
    }

    if (transaction.quantity <= 0) {
      return 'Quantity must be greater than zero';
    }

    if (!hasRequiredProofImage(transaction)) {
      return 'Proof image is required for this transaction type';
    }

    if (!hasRequiredNote(transaction)) {
      return 'Note is required for lost or damaged transactions';
    }

    return null;
  }

  static String? validateUpdateTransaction(
    TransactionModel updatedTransaction,
  ) {
    final transactionId = updatedTransaction.id;

    if (transactionId == null || transactionId.isEmpty) {
      return 'Transaction ID was not found';
    }

    if (updatedTransaction.workerId == null ||
        updatedTransaction.workerId!.isEmpty) {
      return 'Worker ID was not found';
    }

    if (updatedTransaction.toolId == null ||
        updatedTransaction.toolId!.isEmpty) {
      return 'Tool ID was not found';
    }

    if (updatedTransaction.quantity <= 0) {
      return 'Quantity must be greater than zero';
    }

    if (!hasRequiredProofImage(updatedTransaction)) {
      return 'Proof image is required for this transaction type';
    }

    if (!hasRequiredNote(updatedTransaction)) {
      return 'Note is required for lost or damaged transactions';
    }

    return null;
  }

  static String? validateLostDamagedPendingTransaction(
    TransactionModel transaction,
  ) {
    final transactionId = transaction.id;

    if (transactionId == null || transactionId.trim().isEmpty) {
      return 'Transaction ID was not found';
    }

    if (!transaction.isLostOrDamaged) {
      return 'This action is allowed only for lost or damaged transactions';
    }

    if (!transaction.isApprovalPending) {
      return 'This action is allowed only while approval is pending';
    }

    return null;
  }

  static bool hasRequiredProofImage(TransactionModel transaction) {
    if (!transaction.isIssue && !transaction.isDamaged) {
      return true;
    }

    final imagePath = transaction.imagePath;

    return imagePath != null && imagePath.trim().isNotEmpty;
  }

  static bool hasRequiredNote(TransactionModel transaction) {
    if (!transaction.isLost && !transaction.isDamaged) {
      return true;
    }

    final note = transaction.note;

    return note != null && note.trim().isNotEmpty;
  }

  static bool hasApprovalDocument(TransactionModel transaction) {
    final approvalDocumentPath = transaction.approvalDocumentPath;

    return approvalDocumentPath != null &&
        approvalDocumentPath.trim().isNotEmpty;
  }
}
