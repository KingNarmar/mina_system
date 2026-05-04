import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';
import 'package:mina_system/features/transactions/data/models/custody_balance_model.dart';
import 'package:mina_system/features/transactions/data/models/tool_custody_summary_model.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_state.dart';
import 'package:mina_system/features/transactions/presentation/functions/format_transaction_date.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_type_helpers.dart';

class ReportPreviewPlaceholder extends StatelessWidget {
  const ReportPreviewPlaceholder({super.key, required this.reportType});

  final ReportType reportType;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsCubit, TransactionsState>(
      builder: (context, state) {
        final transactionsCubit = context.read<TransactionsCubit>();

        return Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Preview', style: AppTextStyles.title),
              const Gap(12),
              _buildPreviewContent(transactionsCubit),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreviewContent(TransactionsCubit transactionsCubit) {
    switch (reportType) {
      case ReportType.workerCustody:
        return _WorkerCustodyPreview(
          balances: transactionsCubit.getCustodyBalances(),
        );
      case ReportType.toolHistory:
        return _TransactionListPreview(
          transactions: transactionsCubit.state.transactions,
          emptyMessage: 'No tool history transactions found yet.',
        );
      case ReportType.transactions:
        return _TransactionListPreview(
          transactions: transactionsCubit.state.transactions,
          emptyMessage: 'No transactions found yet.',
        );
      case ReportType.lostDamaged:
        return _TransactionListPreview(
          transactions: transactionsCubit.state.transactions.where((item) {
            return item.isLost || item.isDamaged;
          }).toList(),
          emptyMessage: 'No lost or damaged transactions found yet.',
        );
      case ReportType.toolSummary:
        return _ToolSummaryPreview(
          summaries: transactionsCubit.getToolCustodySummaries(),
        );
    }
  }
}

class _WorkerCustodyPreview extends StatelessWidget {
  const _WorkerCustodyPreview({required this.balances});

  final List<CustodyBalanceModel> balances;

  @override
  Widget build(BuildContext context) {
    if (balances.isEmpty) {
      return const _ReportEmptyPreview(
        icon: Icons.assignment_outlined,
        message: 'No open custody balances found yet.',
      );
    }

    return Column(
      children: [
        _ReportMetricRow(
          label: 'Open custody records',
          value: balances.length.toString(),
        ),
        const Gap(12),
        ...balances.take(5).map((balance) {
          return _PreviewTile(
            icon: Icons.assignment_outlined,
            title: balance.workerName,
            subtitle:
                '${balance.toolName} • ${balance.balanceQuantity} ${balance.unit}',
          );
        }),
        if (balances.length > 5)
          _MoreItemsNote(remainingCount: balances.length - 5),
      ],
    );
  }
}

class _ToolSummaryPreview extends StatelessWidget {
  const _ToolSummaryPreview({required this.summaries});

  final List<ToolCustodySummaryModel> summaries;

  @override
  Widget build(BuildContext context) {
    if (summaries.isEmpty) {
      return const _ReportEmptyPreview(
        icon: Icons.summarize_outlined,
        message: 'No tool summary data found yet.',
      );
    }

    final openCustodyTotal = summaries.fold<double>(
      0,
      (total, item) => total + item.openCustodyQuantity,
    );

    return Column(
      children: [
        _ReportMetricRow(
          label: 'Tool types with movements',
          value: summaries.length.toString(),
        ),
        const Gap(8),
        _ReportMetricRow(
          label: 'Total open custody quantity',
          value: openCustodyTotal.toStringAsFixed(2),
        ),
        const Gap(12),
        ...summaries.take(5).map((summary) {
          return _PreviewTile(
            icon: Icons.build_outlined,
            title: summary.toolName,
            subtitle:
                'Issued: ${summary.issuedQuantity} • Returned: ${summary.returnedQuantity} • Open: ${summary.openCustodyQuantity}',
          );
        }),
        if (summaries.length > 5)
          _MoreItemsNote(remainingCount: summaries.length - 5),
      ],
    );
  }
}

class _TransactionListPreview extends StatelessWidget {
  const _TransactionListPreview({
    required this.transactions,
    required this.emptyMessage,
  });

  final List<TransactionModel> transactions;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return _ReportEmptyPreview(
        icon: Icons.receipt_long_outlined,
        message: emptyMessage,
      );
    }

    return Column(
      children: [
        _ReportMetricRow(
          label: 'Total matching transactions',
          value: transactions.length.toString(),
        ),
        const Gap(12),
        ...transactions.take(5).map((transaction) {
          final typeLabel = getTransactionTypeLabel(transaction.type);

          return _PreviewTile(
            icon: getTransactionTypeIcon(transaction.type),
            title: '${transaction.transactionCode} • $typeLabel',
            subtitle:
                '${transaction.workerName} • ${transaction.toolName} • ${transaction.quantity} ${transaction.unit} • ${formatTransactionDate(transaction.dateTime)}',
          );
        }),
        if (transactions.length > 5)
          _MoreItemsNote(remainingCount: transactions.length - 5),
      ],
    );
  }
}

class _ReportMetricRow extends StatelessWidget {
  const _ReportMetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body)),
          const Gap(12),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent, size: 22),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(4),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreItemsNote extends StatelessWidget {
  const _MoreItemsNote({required this.remainingCount});

  final int remainingCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '+$remainingCount more items will be included in the full report.',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ReportEmptyPreview extends StatelessWidget {
  const _ReportEmptyPreview({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textSecondary),
        const Gap(12),
        Expanded(child: Text(message, style: AppTextStyles.body)),
      ],
    );
  }
}
