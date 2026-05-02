import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/transactions/data/models/tool_custody_summary_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/widgets/tool_custody_summary/tool_custody_summary_search_field.dart';
import 'package:mina_system/features/transactions/presentation/widgets/tool_custody_summary/tool_custody_summary_table.dart';

class ToolCustodySummaryDesktopLayout extends StatelessWidget {
  const ToolCustodySummaryDesktopLayout({super.key, required this.summaries});

  final List<ToolCustodySummaryModel> summaries;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = math.max(constraints.maxWidth, 1100.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              ToolCustodySummarySearchField(
                onChanged: (value) {
                  context.read<TransactionsCubit>().searchToolSummaries(value);
                },
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: ToolCustodySummaryTable(summaries: summaries),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
