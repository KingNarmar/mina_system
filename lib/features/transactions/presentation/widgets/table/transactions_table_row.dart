import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/format_transaction_date.dart';
import 'package:mina_system/features/transactions/presentation/widgets/table/transactions_table_cell.dart';

class TransactionsTableRow extends StatelessWidget {
  const TransactionsTableRow({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final typeLabel = transaction.isIssue ? 'Issue' : 'Return';
    final typeColor = transaction.isIssue ? AppColors.error : AppColors.accent;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
              TransactionsTableBodyCell(
                value: formatTransactionDate(transaction.dateTime),
                flex: 2,
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
      ],
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
