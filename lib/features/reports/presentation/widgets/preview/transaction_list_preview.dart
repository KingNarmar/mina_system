import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/format_transaction_date.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_type_helpers.dart';
import 'report_empty_preview.dart';
import 'report_metric_row.dart';
import 'preview_tile.dart';
import 'more_items_note.dart';
import 'package:mina_system/core/theme/app_icons.dart';

class TransactionListPreview extends StatelessWidget {
  const TransactionListPreview({
    super.key,
    required this.transactions,
    required this.emptyMessage,
  });

  final List<TransactionModel> transactions;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return ReportEmptyPreview(
        icon: AppIcons.receiptLongOutlined,
        message: emptyMessage,
      );
    }

    return Column(
      children: [
        ReportMetricRow(
          label: 'Total matching transactions',
          value: transactions.length.toString(),
        ),
        const Gap(12),
        ...transactions.take(5).map((transaction) {
          final typeLabel = getTransactionTypeLabel(transaction.type);

          return PreviewTile(
            icon: getTransactionTypeIcon(transaction.type),
            title: '${transaction.transactionCode} • $typeLabel',
            subtitle:
                '${transaction.workerName} • ${transaction.toolName} • ${transaction.quantity} ${transaction.unit} • ${formatTransactionDate(transaction.dateTime)}',
          );
        }),
        if (transactions.length > 5)
          MoreItemsNote(remainingCount: transactions.length - 5),
      ],
    );
  }
}
