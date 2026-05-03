import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/widgets/app_empty_state.dart';
import 'package:mina_system/features/transactions/data/models/tool_custody_summary_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/widgets/tool_custody_summary/card/tool_custody_summary_card.dart';
import 'package:mina_system/features/transactions/presentation/widgets/tool_custody_summary/tool_custody_summary_search_field.dart';
import 'package:gap/gap.dart';

class ToolCustodySummaryMobileLayout extends StatelessWidget {
  const ToolCustodySummaryMobileLayout({super.key, required this.summaries});

  final List<ToolCustodySummaryModel> summaries;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        itemCount: summaries.isEmpty ? 2 : summaries.length + 1,
        separatorBuilder: (context, index) {
          return const Gap(12);
        },
        itemBuilder: (context, index) {
          if (index == 0) {
            return ToolCustodySummarySearchField(
              onChanged: (value) {
                context.read<TransactionsCubit>().searchToolSummaries(value);
              },
            );
          }

          if (summaries.isEmpty) {
            return const AppEmptyState(
              icon: Icons.summarize_outlined,
              title: 'No tool summary found',
              message:
                  'Tool summaries will appear here after custody transactions are recorded.',
            );
          }

          final summary = summaries[index - 1];

          return ToolCustodySummaryCard(summary: summary);
        },
      ),
    );
  }
}
