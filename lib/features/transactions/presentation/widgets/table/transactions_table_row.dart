import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mina_system/core/services/network_status_service.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_icons.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/utils/app_error_message.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/format_transaction_date.dart';
import 'package:mina_system/features/transactions/presentation/functions/show_transaction_details.dart';
import 'package:mina_system/features/transactions/presentation/functions/show_transaction_image_preview.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_type_helpers.dart';
import 'package:mina_system/features/transactions/presentation/widgets/table/transactions_table_cell.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionsTableRow extends StatelessWidget {
  const TransactionsTableRow({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final typeLabel = getTransactionTypeLabel(transaction.type);
    final typeColor = getTransactionTypeColor(transaction.type);

    return Column(
      children: [
        InkWell(
          onTap: () {
            showTransactionDetails(context, transaction);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                TransactionsTableBodyCell(
                  value: transaction.transactionCode,
                  flex: 2,
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _TransactionTypeBadge(
                          label: typeLabel,
                          color: typeColor,
                        ),
                        if (transaction.isVoided)
                          const _TransactionTypeBadge(
                            label: 'Voided',
                            color: AppColors.error,
                          ),
                      ],
                    ),
                  ),
                ),
                TransactionsTableBodyCell(
                  value:
                      '${transaction.workerName} (${transaction.workerHrCode})',
                  flex: 3,
                ),
                TransactionsTableBodyCell(
                  value: '${transaction.toolName} (${transaction.toolCode})',
                  flex: 3,
                ),
                TransactionsTableBodyCell(
                  value: '${transaction.quantity} ${transaction.unit}',
                  flex: 1,
                ),
                Expanded(
                  flex: 1,
                  child: _TransactionProofPreview(transaction: transaction),
                ),
                TransactionsTableBodyCell(
                  value: formatTransactionDate(
                    transaction.dateTime,
                    timezone: context.currentCompany?.timezone,
                  ),
                  flex: 2,
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}

class _TransactionProofPreview extends StatelessWidget {
  const _TransactionProofPreview({required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final imagePath = transaction.imagePath;
    final hasImage = imagePath != null && imagePath.trim().isNotEmpty;

    final hasNote =
        transaction.note != null && transaction.note!.trim().isNotEmpty;

    if (hasImage) {
      return Align(
        alignment: Alignment.centerLeft,
        child: _TransactionThumbnail(imagePath: imagePath),
      );
    }

    if (hasNote) {
      return Text(
        'Note',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return const Text('-', style: AppTextStyles.caption);
  }
}

class _TransactionThumbnail extends StatelessWidget {
  const _TransactionThumbnail({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ThumbnailImageResult>(
      future: _resolveTransactionImageSource(imagePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _ThumbnailFallback(icon: AppIcons.image);
        }

        final result = snapshot.data;

        if (result == null || !result.hasImageSource) {
          return _ThumbnailFallback(
            icon: result?.isOffline == true
                ? AppIcons.offline
                : AppIcons.brokenImage,
            onTap: () {
              AppMessage.showWarning(
                context,
                result?.message ??
                    'Unable to load proof image. Please try again.',
              );
            },
          );
        }

        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            showTransactionImagePreview(context, result.imageSource!);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 44,
              height: 36,
              child: result.isLocalFile
                  ? Image.file(
                      File(result.imageSource!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _ThumbnailFallback(
                          icon: AppIcons.brokenImage,
                          onTap: () {
                            AppMessage.showWarning(
                              context,
                              AppErrorMessage.fromError(
                                error,
                                fallback:
                                    'Unable to load proof image. Please try again.',
                              ),
                            );
                          },
                        );
                      },
                    )
                  : Image.network(
                      result.imageSource!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _ThumbnailFallback(
                          icon: AppIcons.brokenImage,
                          onTap: () {
                            AppMessage.showWarning(
                              context,
                              AppErrorMessage.fromError(
                                error,
                                fallback:
                                    'Unable to load proof image. Please try again.',
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
        );
      },
    );
  }

  Future<_ThumbnailImageResult> _resolveTransactionImageSource(
    String path,
  ) async {
    try {
      final cleanPath = path.trim();

      if (cleanPath.isEmpty) {
        return const _ThumbnailImageResult.failure(
          message: 'No proof image attached.',
        );
      }

      final localFile = File(cleanPath);

      if (await localFile.exists()) {
        return _ThumbnailImageResult.local(cleanPath);
      }

      if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
        return _ThumbnailImageResult.remote(cleanPath);
      }

      await NetworkStatusService().ensureOnline();

      final signedUrl = await Supabase.instance.client.storage
          .from('transaction-proofs')
          .createSignedUrl(cleanPath, 60 * 60);

      return _ThumbnailImageResult.remote(signedUrl);
    } on NetworkUnavailableException {
      return const _ThumbnailImageResult.failure(
        message:
            'Proof images are stored online and cannot be viewed while offline.',
        isOffline: true,
      );
    } catch (error) {
      return _ThumbnailImageResult.failure(
        message: AppErrorMessage.fromError(
          error,
          fallback: 'Unable to load proof image. Please try again.',
        ),
      );
    }
  }
}

class _ThumbnailImageResult {
  const _ThumbnailImageResult.remote(this.imageSource)
    : message = null,
      isOffline = false,
      isLocalFile = false;

  const _ThumbnailImageResult.local(this.imageSource)
    : message = null,
      isOffline = false,
      isLocalFile = true;

  const _ThumbnailImageResult.failure({
    required this.message,
    this.isOffline = false,
  }) : imageSource = null,
       isLocalFile = false;

  final String? imageSource;
  final String? message;
  final bool isOffline;
  final bool isLocalFile;

  bool get hasImageSource =>
      imageSource != null && imageSource!.trim().isNotEmpty;
}

class _ThumbnailFallback extends StatelessWidget {
  const _ThumbnailFallback({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: 44,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: AppColors.textSecondary),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: content,
    );
  }
}

class _TransactionTypeBadge extends StatelessWidget {
  const _TransactionTypeBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
