import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/functions/show_transaction_details.dart';

enum _ApprovalDocumentSource { camera, file }

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

  bool get _canCaptureApprovalDocumentPhoto {
    if (kIsWeb) {
      return false;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      TargetPlatform.fuchsia ||
      TargetPlatform.linux ||
      TargetPlatform.macOS ||
      TargetPlatform.windows => false,
    };
  }

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

  Future<String?> _selectApprovalDocumentPath(BuildContext context) async {
    if (!_canCaptureApprovalDocumentPhoto) {
      return _pickApprovalDocumentFile(context);
    }

    final selectedSource = await showModalBottomSheet<_ApprovalDocumentSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ApprovalDocumentSourceTile(
                  icon: Icons.photo_camera_outlined,
                  title: 'Take Photo',
                  subtitle: 'Capture the signed approval document.',
                  onTap: () {
                    Navigator.of(
                      bottomSheetContext,
                    ).pop(_ApprovalDocumentSource.camera);
                  },
                ),
                _ApprovalDocumentSourceTile(
                  icon: Icons.attach_file_rounded,
                  title: 'Choose File',
                  subtitle: 'Select a PDF, JPG, PNG, or WEBP file.',
                  onTap: () {
                    Navigator.of(
                      bottomSheetContext,
                    ).pop(_ApprovalDocumentSource.file);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!context.mounted || selectedSource == null) {
      return null;
    }

    return switch (selectedSource) {
      _ApprovalDocumentSource.camera => _takeApprovalDocumentPhoto(context),
      _ApprovalDocumentSource.file => _pickApprovalDocumentFile(context),
    };
  }

  Future<String?> _takeApprovalDocumentPhoto(BuildContext context) async {
    try {
      final photo = await ImagePicker().pickImage(source: ImageSource.camera);

      return photo?.path;
    } catch (_) {
      if (!context.mounted) {
        return null;
      }

      AppMessage.showError(
        context,
        'Could not open the camera. Please choose a file instead.',
      );

      return null;
    }
  }

  Future<String?> _pickApprovalDocumentFile(BuildContext context) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
        withData: false,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      return result.files.single.path;
    } catch (_) {
      if (!context.mounted) {
        return null;
      }

      AppMessage.showError(
        context,
        'Could not choose the approval document. Please try again.',
      );

      return null;
    }
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

class _ApprovalDocumentSourceTile extends StatelessWidget {
  const _ApprovalDocumentSourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
