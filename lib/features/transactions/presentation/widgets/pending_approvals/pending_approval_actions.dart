import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/functions/show_transaction_details.dart';

class PendingApprovalActions extends StatelessWidget {
  const PendingApprovalActions({super.key, required this.transaction});

  final TransactionModel transaction;

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
        if (transaction.isApprovalPending)
          OutlinedButton.icon(
            onPressed: () {
              _pickAndUploadApprovalDocument(context, transaction);
            },
            icon: const Icon(Icons.upload_file_outlined, size: 18),
            label: Text(
              hasApprovalDocument ? 'Replace Signed' : 'Upload Signed',
            ),
          ),
        if (transaction.isApprovalPending)
          ElevatedButton.icon(
            onPressed: hasApprovalDocument
                ? () {
                    _approveTransaction(context, transaction);
                  }
                : null,
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Approve'),
          ),
        if (transaction.isApprovalPending)
          OutlinedButton.icon(
            onPressed: hasApprovalDocument
                ? () {
                    _rejectTransaction(context, transaction);
                  }
                : null,
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('Reject'),
          ),
        if (transaction.isApprovalApproved && transaction.isPendingSettlement)
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

    final success = await context
        .read<TransactionsCubit>()
        .uploadApprovalDocument(
          transaction: transaction,
          localDocumentPath: path,
        );

    if (!context.mounted || !success) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signed approval document uploaded')),
    );
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

    final success = await context.read<TransactionsCubit>().approveTransaction(
      transaction: transaction,
      decidedByProfileId: context.currentProfileId ?? '',
    );

    if (!context.mounted || !success) {
      return;
    }

    await _refreshDashboard(context);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Transaction approved')));
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

    final success = await context.read<TransactionsCubit>().rejectTransaction(
      transaction: transaction,
      decidedByProfileId: context.currentProfileId ?? '',
    );

    if (!context.mounted || !success) {
      return;
    }

    await _refreshDashboard(context);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Transaction rejected')));
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

    final success = await context.read<TransactionsCubit>().settleTransaction(
      transaction: transaction,
      settledByProfileId: context.currentProfileId ?? '',
    );

    if (!context.mounted || !success) {
      return;
    }

    await _refreshDashboard(context);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Transaction settled')));
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
