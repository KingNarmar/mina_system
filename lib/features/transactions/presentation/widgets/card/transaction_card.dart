import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/format_transaction_date.dart';
import 'package:mina_system/features/transactions/presentation/functions/show_transaction_details.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_type_helpers.dart';
import 'package:mina_system/features/transactions/presentation/widgets/card/transaction_info_row.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final typeLabel = getTransactionTypeLabel(transaction.type);
    final typeColor = getTransactionTypeColor(transaction.type);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        showTransactionDetails(context, transaction);
      },
      child: Card(
        elevation: 0,
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: typeColor.withValues(alpha: 0.12),
                    child: Icon(getTransactionTypeIcon(transaction.type)),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Text(
                      transaction.transactionCode,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
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
              const Gap(16),
              TransactionInfoRow(
                label: 'Worker',
                value:
                    '${transaction.workerName} (${transaction.workerHrCode})',
              ),
              TransactionInfoRow(
                label: 'Tool',
                value: '${transaction.toolName} (${transaction.toolCode})',
              ),
              TransactionInfoRow(
                label: 'Quantity',
                value: '${transaction.quantity} ${transaction.unit}',
              ),
              TransactionInfoRow(
                label: 'Date',
                value: formatTransactionDate(
                  transaction.dateTime,
                  timezone: context.currentCompany?.timezone,
                ),
              ),
              if (transaction.imagePath != null &&
                  transaction.imagePath!.trim().isNotEmpty)
                const TransactionInfoRow(label: 'Photo', value: 'Attached'),
              if (transaction.note != null &&
                  transaction.note!.trim().isNotEmpty)
                TransactionInfoRow(label: 'Note', value: transaction.note!),
            ],
          ),
        ),
      ),
    );
  }
}
