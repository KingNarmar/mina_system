import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/transactions/data/models/tool_custody_summary_model.dart';
import 'package:mina_system/features/transactions/presentation/widgets/tool_custody_summary/table/tool_custody_summary_table_header.dart';
import 'package:mina_system/features/transactions/presentation/widgets/tool_custody_summary/table/tool_custody_summary_table_row.dart';

class ToolCustodySummaryTable extends StatelessWidget {
  const ToolCustodySummaryTable({super.key, required this.summaries});

  final List<ToolCustodySummaryModel> summaries;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        children: [
          const ToolCustodySummaryTableHeader(),
          const Divider(height: 1, color: AppColors.border),
          if (summaries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No tool custody summary found',
                style: AppTextStyles.body,
              ),
            )
          else
            ...summaries.map((summary) {
              return ToolCustodySummaryTableRow(summary: summary);
            }),
        ],
      ),
    );
  }
}
