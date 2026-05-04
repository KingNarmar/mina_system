import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/reports/data/models/report_filter_model.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';
import 'package:mina_system/features/reports/presentation/functions/report_filter_helpers.dart';
import 'package:mina_system/features/transactions/data/models/custody_balance_model.dart';
import 'package:mina_system/features/transactions/data/models/tool_custody_summary_model.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_state.dart';
import 'package:mina_system/features/transactions/presentation/functions/custody_balance_calculator.dart';
import 'package:mina_system/features/transactions/presentation/functions/format_transaction_date.dart';
import 'package:mina_system/features/transactions/presentation/functions/tool_summary_calculator.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_type_helpers.dart';

class ReportPreviewSection extends StatelessWidget {
  const ReportPreviewSection({
    super.key,
    required this.reportType,
    required this.filters,
  });

  final ReportType reportType;
  final ReportFilterModel filters;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsCubit, TransactionsState>(
      builder: (context, state) {
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
              _buildPreviewContent(state.transactions),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreviewContent(List<TransactionModel> transactions) {
    switch (reportType) {
      case ReportType.workerCustody:
        final filteredTransactions = applyReportTransactionFilters(
          transactions: transactions,
          filters: filters,
        );

        return _WorkerCustodyPreview(
          balances: calculateCustodyBalances(filteredTransactions),
        );

      case ReportType.toolHistory:
        final filteredTransactions = applyReportTransactionFilters(
          transactions: transactions,
          filters: filters,
        );

        return _TransactionListPreview(
          transactions: filteredTransactions,
          emptyMessage: filters.hasFilters
              ? 'No matching tool history transactions found.'
              : 'No tool history transactions found yet.',
        );

      case ReportType.transactions:
        final filteredTransactions = applyReportTransactionFilters(
          transactions: transactions,
          filters: filters,
        );

        return _TransactionListPreview(
          transactions: filteredTransactions,
          emptyMessage: filters.hasFilters
              ? 'No matching transactions found for the selected filters.'
              : 'No transactions found yet.',
        );

      case ReportType.lostDamaged:
        final filteredTransactions = applyReportTransactionFilters(
          transactions: transactions,
          filters: filters,
          lostDamagedOnly: true,
        );

        return _TransactionListPreview(
          transactions: filteredTransactions,
          emptyMessage: filters.hasFilters
              ? 'No matching lost or damaged transactions found.'
              : 'No lost or damaged transactions found yet.',
        );

      case ReportType.toolSummary:
        final filteredTransactions = applyReportTransactionFilters(
          transactions: transactions,
          filters: filters,
        );

        return _ToolSummaryPreview(
          summaries: calculateToolCustodySummaries(filteredTransactions),
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
        message: 'No open custody balances found for the selected filters.',
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
        message: 'No tool summary data found for the selected filters.',
      );
    }

    final openCustodyTotal = summaries.fold<double>(
      0,
      (total, item) => total + item.openCustodyQuantity,
    );

    final lostTotal = summaries.fold<double>(
      0,
      (total, item) => total + item.lostQuantity,
    );

    final damagedTotal = summaries.fold<double>(
      0,
      (total, item) => total + item.damagedQuantity,
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
        const Gap(8),
        _ReportMetricRow(
          label: 'Total lost quantity',
          value: lostTotal.toStringAsFixed(2),
        ),
        const Gap(8),
        _ReportMetricRow(
          label: 'Total damaged quantity',
          value: damagedTotal.toStringAsFixed(2),
        ),
        const Gap(12),
        ...summaries.take(5).map((summary) {
          return _PreviewTile(
            icon: Icons.build_outlined,
            title: summary.toolName,
            subtitle:
                'Issued: ${summary.issuedQuantity} • Returned: ${summary.returnedQuantity} • Lost: ${summary.lostQuantity} • Damaged: ${summary.damagedQuantity} • Open: ${summary.openCustodyQuantity}',
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
