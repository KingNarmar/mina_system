import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/features/transactions/data/models/tool_custody_summary_model.dart';
import 'report_empty_preview.dart';
import 'report_metric_row.dart';
import 'preview_tile.dart';
import 'more_items_note.dart';

class ToolSummaryPreview extends StatelessWidget {
  const ToolSummaryPreview({super.key, required this.summaries});

  final List<ToolCustodySummaryModel> summaries;

  @override
  Widget build(BuildContext context) {
    if (summaries.isEmpty) {
      return const ReportEmptyPreview(
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
        ReportMetricRow(
          label: 'Tool types with movements',
          value: summaries.length.toString(),
        ),
        const Gap(8),
        ReportMetricRow(
          label: 'Total open custody quantity',
          value: openCustodyTotal.toStringAsFixed(2),
        ),
        const Gap(8),
        ReportMetricRow(
          label: 'Total lost quantity',
          value: lostTotal.toStringAsFixed(2),
        ),
        const Gap(8),
        ReportMetricRow(
          label: 'Total damaged quantity',
          value: damagedTotal.toStringAsFixed(2),
        ),
        const Gap(12),
        ...summaries.take(5).map((summary) {
          return PreviewTile(
            icon: Icons.build_outlined,
            title: summary.toolName,
            subtitle:
                'Issued: ${summary.issuedQuantity} • Returned: ${summary.returnedQuantity} • Lost: ${summary.lostQuantity} • Damaged: ${summary.damagedQuantity} • Open: ${summary.openCustodyQuantity}',
          );
        }),
        if (summaries.length > 5)
          MoreItemsNote(remainingCount: summaries.length - 5),
      ],
    );
  }
}
