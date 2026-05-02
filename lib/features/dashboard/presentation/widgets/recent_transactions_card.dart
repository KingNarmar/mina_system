import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/functions/format_transaction_date.dart';

class RecentTransactionsCard extends StatelessWidget {
  const RecentTransactionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = context
        .watch<TransactionsCubit>()
        .state
        .transactions
        .take(4)
        .toList();

    return Card(
      elevation: 0,
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Transactions', style: AppTextStyles.title),
            const SizedBox(height: 16),
            if (transactions.isEmpty)
              Text(
                'No recent transactions yet',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            else
              ...transactions.map((transaction) {
                return _RecentTransactionItem(transaction: transaction);
              }),
          ],
        ),
      ),
    );
  }
}

class _RecentTransactionItem extends StatelessWidget {
  const _RecentTransactionItem({required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final typeLabel = transaction.isIssue ? 'Issue' : 'Return';
    final typeColor = transaction.isIssue ? AppColors.error : AppColors.accent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: typeColor.withValues(alpha: 0.12),
            child: Icon(
              transaction.isIssue
                  ? Icons.north_east_outlined
                  : Icons.south_west_outlined,
              size: 18,
              color: typeColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.workerName,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$typeLabel • ${transaction.toolName} • ${transaction.quantity} ${transaction.unit}',
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatTransactionDate(transaction.dateTime),
            style: AppTextStyles.caption,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
