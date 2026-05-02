import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/format_transaction_date.dart';
import 'package:mina_system/features/transactions/presentation/functions/show_transaction_details.dart';
import 'package:mina_system/features/transactions/presentation/functions/show_transaction_image_preview.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_type_helpers.dart';
import 'package:mina_system/features/transactions/presentation/widgets/table/transactions_table_cell.dart';

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
                    child: _TransactionTypeBadge(
                      label: typeLabel,
                      color: typeColor,
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
                  value: formatTransactionDate(transaction.dateTime),
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
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            showTransactionImagePreview(context, imagePath);
          },
          child: _TransactionThumbnail(imagePath: imagePath),
        ),
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

    return const Text('-');
  }
}

class _TransactionThumbnail extends StatelessWidget {
  const _TransactionThumbnail({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final isNetworkImage =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 44,
        height: 36,
        child: isNetworkImage
            ? Image.network(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const _ThumbnailFallback();
                },
              )
            : Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const _ThumbnailFallback();
                },
              ),
      ),
    );
  }
}

class _ThumbnailFallback extends StatelessWidget {
  const _ThumbnailFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.border,
      child: const Icon(
        Icons.broken_image_outlined,
        size: 18,
        color: AppColors.textSecondary,
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
