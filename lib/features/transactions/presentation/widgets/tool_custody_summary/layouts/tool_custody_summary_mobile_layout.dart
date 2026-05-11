import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/widgets/app_empty_state.dart';
import 'package:mina_system/features/transactions/data/models/tool_custody_summary_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/widgets/tool_custody_summary/card/tool_custody_summary_card.dart';
import 'package:mina_system/features/transactions/presentation/widgets/tool_custody_summary/tool_custody_summary_search_field.dart';

class ToolCustodySummaryMobileLayout extends StatelessWidget {
  const ToolCustodySummaryMobileLayout({
    super.key,
    required this.summaries,
    required this.searchQuery,
    this.isCompactSearchMode = false,
    this.onSearchFocusChanged,
  });

  final List<ToolCustodySummaryModel> summaries;
  final String searchQuery;
  final bool isCompactSearchMode;
  final ValueChanged<bool>? onSearchFocusChanged;

  @override
  Widget build(BuildContext context) {
    final keyboardBottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: ListView.separated(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          isCompactSearchMode ? 16 : 24,
          isCompactSearchMode ? 8 : 24,
          isCompactSearchMode ? 16 : 24,
          keyboardBottomInset > 0 ? keyboardBottomInset + 16 : 100,
        ),
        itemCount: summaries.isEmpty ? 2 : summaries.length + 1,
        separatorBuilder: (context, index) {
          return const Gap(12);
        },
        itemBuilder: (context, index) {
          if (index == 0) {
            return ToolCustodySummarySearchField(
              initialQuery: searchQuery,
              onFocusChanged: onSearchFocusChanged,
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
