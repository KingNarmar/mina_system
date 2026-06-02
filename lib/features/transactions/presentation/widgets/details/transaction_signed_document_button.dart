import 'package:flutter/material.dart';
import 'package:mina_system/core/services/network_status_service.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/utils/app_error_message.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/data/repo/transactions_repo.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mina_system/core/theme/app_icons.dart';

class TransactionSignedDocumentButton extends StatelessWidget {
  const TransactionSignedDocumentButton({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        onPressed: () {
          _openApprovalDocument(context, transaction);
        },
        icon: const Icon(AppIcons.openInNew, size: 18),
        label: const Text('View Signed Document'),
      ),
    );
  }

  Future<void> _openApprovalDocument(
    BuildContext context,
    TransactionModel transaction,
  ) async {
    try {
      await NetworkStatusService().ensureOnline();

      final signedUrl = await TransactionsRepo()
          .createApprovalDocumentSignedUrl(transaction: transaction);

      final uri = Uri.parse(signedUrl);

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        if (!context.mounted) return;

        _showDocumentMessageDialog(
          context: context,
          title: 'Unable to open document',
          message: 'Unable to open signed document.',
          icon: AppIcons.error,
          iconColor: AppColors.error,
        );
      }
    } on NetworkUnavailableException catch (_) {
      if (!context.mounted) return;

      _showDocumentMessageDialog(
        context: context,
        title: 'Offline mode',
        message:
            'Signed documents are stored online and cannot be opened while offline.',
        icon: AppIcons.offline,
        iconColor: AppColors.warning,
      );
    } catch (error) {
      if (!context.mounted) return;

      _showDocumentMessageDialog(
        context: context,
        title: 'Unable to open document',
        message: AppErrorMessage.fromError(
          error,
          fallback: 'Unable to open signed document. Please try again.',
        ),
        icon: AppIcons.error,
        iconColor: AppColors.error,
      );
    }
  }

  Future<void> _showDocumentMessageDialog({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(icon, color: iconColor, size: 36),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
