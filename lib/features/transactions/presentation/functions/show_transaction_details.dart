import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/format_quantity.dart';
import 'package:mina_system/features/transactions/presentation/functions/format_transaction_date.dart';
import 'package:mina_system/features/transactions/presentation/functions/show_transaction_image_preview.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_type_helpers.dart';
import 'package:gap/gap.dart';

void showTransactionDetails(
  BuildContext context,
  TransactionModel transaction,
) {
  showDialog(
    context: context,
    builder: (_) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _TransactionDetailsContent(transaction: transaction),
          ),
        ),
      );
    },
  );
}

class _TransactionDetailsContent extends StatelessWidget {
  const _TransactionDetailsContent({required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final typeLabel = getTransactionTypeLabel(transaction.type);
    final typeColor = getTransactionTypeColor(transaction.type);

    final hasImage =
        transaction.imagePath != null &&
        transaction.imagePath!.trim().isNotEmpty;

    final hasNote =
        transaction.note != null && transaction.note!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: typeColor.withValues(alpha: 0.12),
              child: Icon(
                getTransactionTypeIcon(transaction.type),
                color: typeColor,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Text(
                transaction.transactionCode,
                style: AppTextStyles.title,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                typeLabel,
                style: AppTextStyles.caption.copyWith(
                  color: typeColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const Gap(20),
        _TransactionDetailsRow(
          label: 'Worker',
          value: '${transaction.workerName} (${transaction.workerHrCode})',
        ),
        _TransactionDetailsRow(
          label: 'Tool',
          value: '${transaction.toolName} (${transaction.toolCode})',
        ),
        _TransactionDetailsRow(
          label: 'Quantity',
          value: '${formatQuantity(transaction.quantity)} ${transaction.unit}',
        ),
        _TransactionDetailsRow(
          label: 'Date',
          value: formatTransactionDate(transaction.dateTime),
        ),
        const Gap(16),
        Text(
          'Photo',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(8),
        if (hasImage)
          _TransactionImagePreview(imagePath: transaction.imagePath!)
        else
          const _EmptyDetailsBox(text: 'No photo attached'),
        const Gap(16),
        Text(
          'Note',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(8),
        if (hasNote)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              transaction.note!,
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            ),
          )
        else
          const _EmptyDetailsBox(text: 'No note added'),
        const Gap(20),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ),
      ],
    );
  }
}

class _TransactionDetailsRow extends StatelessWidget {
  const _TransactionDetailsRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: AppTextStyles.caption)),
          const Gap(8),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionImagePreview extends StatelessWidget {
  const _TransactionImagePreview({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final isNetworkImage =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        showTransactionImagePreview(context, imagePath);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: isNetworkImage
            ? Image.network(
                imagePath,
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const _EmptyDetailsBox(text: 'Unable to load image');
                },
              )
            : Image.file(
                File(imagePath),
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const _EmptyDetailsBox(
                    text: 'Unable to load local image',
                  );
                },
              ),
      ),
    );
  }
}

class _EmptyDetailsBox extends StatelessWidget {
  const _EmptyDetailsBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
