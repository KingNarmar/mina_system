part of 'pending_approval_actions.dart';

Future<void> _pickAndUploadApprovalDocument(
  BuildContext context,
  TransactionModel transaction,
) async {
  final localDocumentPath = await _selectApprovalDocumentPath(context);

  if (!context.mounted) {
    return;
  }

  if (localDocumentPath == null || localDocumentPath.trim().isEmpty) {
    return;
  }

  final transactionsCubit = context.read<TransactionsCubit>();

  final success = await transactionsCubit.uploadApprovalDocument(
    transaction: transaction,
    localDocumentPath: localDocumentPath,
  );

  if (!context.mounted) {
    return;
  }

  if (!success) {
    _showTransactionError(context, transactionsCubit);
    return;
  }

  AppMessage.showSuccess(context, 'Signed approval document uploaded');
}

Future<void> _approveTransaction(
  BuildContext context,
  TransactionModel transaction,
) async {
  final confirmed = await _confirmAction(
    context: context,
    title: 'Approve Transaction',
    message: 'Are you sure you want to approve this lost/damaged transaction?',
    confirmText: 'Approve',
  );

  if (!context.mounted || !confirmed) {
    return;
  }

  final transactionsCubit = context.read<TransactionsCubit>();

  final success = await transactionsCubit.approveTransaction(
    transaction: transaction,
  );

  if (!context.mounted) {
    return;
  }

  if (!success) {
    _showTransactionError(context, transactionsCubit);
    return;
  }

  await _refreshDashboard(context);

  if (!context.mounted) {
    return;
  }

  AppMessage.showSuccess(context, 'Transaction approved');
}

Future<void> _rejectTransaction(
  BuildContext context,
  TransactionModel transaction,
) async {
  final confirmed = await _confirmAction(
    context: context,
    title: 'Reject Transaction',
    message: 'Are you sure you want to reject this lost/damaged transaction?',
    confirmText: 'Reject',
  );

  if (!context.mounted || !confirmed) {
    return;
  }

  final transactionsCubit = context.read<TransactionsCubit>();

  final success = await transactionsCubit.rejectTransaction(
    transaction: transaction,
  );

  if (!context.mounted) {
    return;
  }

  if (!success) {
    _showTransactionError(context, transactionsCubit);
    return;
  }

  await _refreshDashboard(context);

  if (!context.mounted) {
    return;
  }

  AppMessage.showSuccess(context, 'Transaction rejected');
}

Future<void> _settleTransaction(
  BuildContext context,
  TransactionModel transaction,
) async {
  final confirmed = await _confirmAction(
    context: context,
    title: 'Settle Transaction',
    message:
        'Are you sure the deduction/settlement is completed for this transaction?',
    confirmText: 'Settle',
  );

  if (!context.mounted || !confirmed) {
    return;
  }

  final transactionsCubit = context.read<TransactionsCubit>();

  final success = await transactionsCubit.settleTransaction(
    transaction: transaction,
  );

  if (!context.mounted) {
    return;
  }

  if (!success) {
    _showTransactionError(context, transactionsCubit);
    return;
  }

  await _refreshDashboard(context);

  if (!context.mounted) {
    return;
  }

  AppMessage.showSuccess(context, 'Transaction settled');
}

void _showTransactionError(
  BuildContext context,
  TransactionsCubit transactionsCubit,
) {
  final message =
      transactionsCubit.state.errorMessage ?? 'Unable to complete action.';

  transactionsCubit.clearErrorMessage();

  AppMessage.showError(context, message);
}

Future<void> _refreshDashboard(BuildContext context) async {
  final companyId = context.currentCompanyId;

  if (companyId == null || companyId.trim().isEmpty) {
    return;
  }

  await context.read<DashboardCubit>().loadDashboardSummary(
    companyId: companyId,
  );
}

Future<bool> _confirmAction({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmText,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: Text(confirmText),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
