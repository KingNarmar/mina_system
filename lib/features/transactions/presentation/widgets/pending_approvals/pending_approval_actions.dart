import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/functions/show_transaction_details.dart';

class PendingApprovalActions extends StatelessWidget {
  const PendingApprovalActions({
    super.key,
    required this.transaction,
    required this.canUploadApprovalDocument,
    required this.canApproveLostDamaged,
    required this.canRejectLostDamaged,
    required this.canSettleLostDamaged,
  });

  final TransactionModel transaction;
  final bool canUploadApprovalDocument;
  final bool canApproveLostDamaged;
  final bool canRejectLostDamaged;
  final bool canSettleLostDamaged;

  @override
  Widget build(BuildContext context) {
    final hasApprovalDocument =
        transaction.approvalDocumentPath != null &&
        transaction.approvalDocumentPath!.trim().isNotEmpty;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: () {
            showTransactionDetails(context, transaction);
          },
          icon: const Icon(Icons.visibility_outlined, size: 18),
          label: const Text('View'),
        ),
        if (transaction.isApprovalPending && canUploadApprovalDocument)
          OutlinedButton.icon(
            onPressed: () {
              _pickAndUploadApprovalDocument(context, transaction);
            },
            icon: const Icon(Icons.upload_file_outlined, size: 18),
            label: Text(
              hasApprovalDocument ? 'Replace Signed' : 'Upload Signed',
            ),
          ),
        if (transaction.isApprovalPending && canApproveLostDamaged)
          ElevatedButton.icon(
            onPressed: hasApprovalDocument
                ? () {
                    _approveTransaction(context, transaction);
                  }
                : null,
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Approve'),
          ),
        if (transaction.isApprovalPending && canRejectLostDamaged)
          OutlinedButton.icon(
            onPressed: hasApprovalDocument
                ? () {
                    _rejectTransaction(context, transaction);
                  }
                : null,
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('Reject'),
          ),
        if (transaction.isApprovalApproved &&
            transaction.isPendingSettlement &&
            canSettleLostDamaged)
          ElevatedButton.icon(
            onPressed: () {
              _settleTransaction(context, transaction);
            },
            icon: const Icon(Icons.price_check_outlined, size: 18),
            label: const Text('Settle'),
          ),
      ],
    );
  }

  Future<void> _pickAndUploadApprovalDocument(
    BuildContext context,
    TransactionModel transaction,
  ) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
      withData: false,
    );

    final path = result?.files.single.path;

    if (path == null || path.trim().isEmpty) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    final transactionsCubit = context.read<TransactionsCubit>();

    final success = await transactionsCubit.uploadApprovalDocument(
      transaction: transaction,
      localDocumentPath: path,
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
      message:
          'Are you sure you want to approve this lost/damaged transaction?',
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
}
