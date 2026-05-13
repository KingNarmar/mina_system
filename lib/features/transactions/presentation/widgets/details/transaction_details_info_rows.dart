import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/format_quantity.dart';
import 'package:mina_system/features/transactions/presentation/functions/format_transaction_date.dart';

class TransactionDetailsInfoRows extends StatelessWidget {
  const TransactionDetailsInfoRows({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TransactionDetailsRow(
          label: 'Worker',
          value: '${transaction.workerName} (${transaction.workerHrCode})',
        ),
        TransactionDetailsRow(
          label: 'Tool',
          value: '${transaction.toolName} (${transaction.toolCode})',
        ),
        TransactionDetailsRow(
          label: 'Quantity',
          value: '${formatQuantity(transaction.quantity)} ${transaction.unit}',
        ),
        TransactionDetailsRow(
          label: 'Date',
          value: formatTransactionDate(
            transaction.dateTime,
            timezone: context.currentCompany?.timezone,
          ),
        ),
      ],
    );
  }
}

class TransactionDetailsRow extends StatelessWidget {
  const TransactionDetailsRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTextStyles.caption),
          ),
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
