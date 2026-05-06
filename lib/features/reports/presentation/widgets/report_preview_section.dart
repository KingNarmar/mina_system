import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/reports/data/models/report_filter_model.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';
import 'package:mina_system/features/reports/presentation/functions/report_filter_helpers.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_state.dart';
import 'package:mina_system/features/transactions/presentation/functions/custody_balance_calculator.dart';
import 'package:mina_system/features/transactions/presentation/functions/tool_summary_calculator.dart';

import 'preview/tool_summary_preview.dart';
import 'preview/transaction_list_preview.dart';
import 'preview/worker_custody_preview.dart';

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

        return WorkerCustodyPreview(
          balances: calculateCustodyBalances(filteredTransactions),
        );

      case ReportType.toolHistory:
        final filteredTransactions = applyReportTransactionFilters(
          transactions: transactions,
          filters: filters,
        );

        return TransactionListPreview(
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

        return TransactionListPreview(
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

        return TransactionListPreview(
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

        return ToolSummaryPreview(
          summaries: calculateToolCustodySummaries(filteredTransactions),
        );
    }
  }
}
