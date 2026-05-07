import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_type_helpers.dart';

class TransactionDetailsHeader extends StatelessWidget {
  const TransactionDetailsHeader({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final typeLabel = getTransactionTypeLabel(transaction.type);
    final typeColor = getTransactionTypeColor(transaction.type);

    return Row(
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
          child: Text(transaction.transactionCode, style: AppTextStyles.title),
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
    );
  }
}
