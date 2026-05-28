import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:mina_system/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/format_quantity.dart';
import 'package:mina_system/features/transactions/presentation/functions/format_transaction_date.dart';
import 'package:mina_system/features/transactions/presentation/functions/show_transaction_details.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_type_helpers.dart';

class RecentTransactionsCard extends StatelessWidget {
  const RecentTransactionsCard({super.key, this.transactions});

  final List<TransactionModel>? transactions;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final resolvedTransactions =
            transactions ?? state.summary.recentTransactions;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardHeader(count: resolvedTransactions.length),
              const Gap(14),
              if (resolvedTransactions.isEmpty)
                const _EmptyRecentTransactions()
              else
                Column(
                  children: resolvedTransactions.map((transaction) {
                    return _RecentTransactionTile(transaction: transaction);
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Recent Activity',
            style: AppTextStyles.title.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          '$count latest',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _RecentTransactionTile extends StatelessWidget {
  const _RecentTransactionTile({required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final typeColor = getTransactionTypeColor(transaction.type);
    final typeLabel = getTransactionTypeLabel(transaction.type);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => showTransactionDetails(context, transaction),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                getTransactionTypeIcon(transaction.type),
                color: typeColor,
                size: 21,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${transaction.transactionCode} • $typeLabel',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(4),
                  Text(
                    '${transaction.workerName} • ${transaction.toolName}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(4),
                  Text(
                    '${formatQuantity(transaction.quantity)} ${transaction.unit} • ${formatTransactionDate(transaction.dateTime)}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Gap(8),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRecentTransactions extends StatelessWidget {
  const _EmptyRecentTransactions();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        'No recent transactions yet.',
        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
