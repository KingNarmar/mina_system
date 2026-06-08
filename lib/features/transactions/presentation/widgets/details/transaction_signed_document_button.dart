import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mina_system/core/services/network_status_service.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_icons.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/utils/app_error_message.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/data/repo/transactions_repo.dart';
import 'package:mina_system/features/transactions/presentation/functions/show_transaction_image_preview.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

class TransactionSignedDocumentButton extends StatelessWidget {
  const TransactionSignedDocumentButton({
    super.key,
    required this.transaction,
    this.label = 'View Signed Document',
    this.compact = false,
  });

  final TransactionModel transaction;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton.icon(
      onPressed: () {
        _openApprovalDocument(context, transaction);
      },
      icon: const Icon(AppIcons.openInNew, size: 18),
      label: Text(label),
    );

    if (compact) {
      return button;
    }

    return Align(alignment: Alignment.centerLeft, child: button);
  }

  Future<void> _openApprovalDocument(
    BuildContext context,
    TransactionModel transaction,
  ) async {
    try {
      final documentPath = transaction.approvalDocumentPath?.trim();

      if (documentPath == null || documentPath.isEmpty) {
        _showDocumentMessageDialog(
          context: context,
          title: 'No document found',
          message: 'No signed approval document is attached.',
          icon: AppIcons.info,
          iconColor: AppColors.warning,
        );
        return;
      }

      final localFile = File(documentPath);
      final isLocalFileAvailable = await localFile.exists();

      if (!context.mounted) {
        return;
      }

      if (isLocalFileAvailable) {
        await _openLocalDocument(context: context, file: localFile);
        return;
      }

      await NetworkStatusService().ensureOnline();

      final signedUrl = await TransactionsRepo()
          .createApprovalDocumentSignedUrl(transaction: transaction);

      final uri = Uri.parse(signedUrl);

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!context.mounted) {
        return;
      }

      if (!launched) {
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

  Future<void> _openLocalDocument({
    required BuildContext context,
    required File file,
  }) async {
    final path = file.path.trim();
    final lowerPath = path.toLowerCase();

    if (_isImagePath(lowerPath)) {
      showTransactionImagePreview(context, path);
      return;
    }

    if (_isPdfPath(lowerPath)) {
      final bytes = await file.readAsBytes();

      if (!context.mounted) {
        return;
      }

      await _showLocalPdfPreview(
        context: context,
        pdfBytes: bytes,
        fileName: _resolveFileName(file),
      );

      return;
    }

    final launched = await launchUrl(
      file.uri,
      mode: LaunchMode.externalApplication,
    );

    if (!context.mounted) {
      return;
    }

    if (!launched) {
      _showDocumentMessageDialog(
        context: context,
        title: 'Unable to open document',
        message: 'This local document type cannot be opened in the app.',
        icon: AppIcons.error,
        iconColor: AppColors.error,
      );
    }
  }

  Future<void> _showLocalPdfPreview({
    required BuildContext context,
    required Uint8List pdfBytes,
    required String fileName,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) {
        return Dialog.fullscreen(
          backgroundColor: AppColors.background,
          child: Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(AppIcons.pdf, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          fileName,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(AppIcons.close),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              Expanded(
                child: PdfPreview(
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  canDebug: false,
                  allowPrinting: true,
                  allowSharing: true,
                  pdfFileName: fileName,
                  build: (_) async {
                    return pdfBytes;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isImagePath(String lowerPath) {
    return lowerPath.endsWith('.jpg') ||
        lowerPath.endsWith('.jpeg') ||
        lowerPath.endsWith('.png') ||
        lowerPath.endsWith('.webp');
  }

  bool _isPdfPath(String lowerPath) {
    return lowerPath.endsWith('.pdf');
  }

  String _resolveFileName(File file) {
    final segments = file.uri.pathSegments;

    if (segments.isEmpty) {
      return 'approval-document.pdf';
    }

    final cleanName = segments.last.trim();

    if (cleanName.isEmpty) {
      return 'approval-document.pdf';
    }

    return cleanName;
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
