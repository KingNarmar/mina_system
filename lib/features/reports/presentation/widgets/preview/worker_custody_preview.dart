import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/features/transactions/data/models/custody_balance_model.dart';
import 'report_empty_preview.dart';
import 'report_metric_row.dart';
import 'preview_tile.dart';
import 'more_items_note.dart';
import 'package:mina_system/core/theme/app_icons.dart';

class WorkerCustodyPreview extends StatelessWidget {
  const WorkerCustodyPreview({super.key, required this.balances});

  final List<CustodyBalanceModel> balances;

  @override
  Widget build(BuildContext context) {
    if (balances.isEmpty) {
      return const ReportEmptyPreview(
        icon: AppIcons.assignmentOutlined,
        message: 'No open custody balances found for the selected filters.',
      );
    }

    return Column(
      children: [
        ReportMetricRow(
          label: 'Open custody records',
          value: balances.length.toString(),
        ),
        const Gap(12),
        ...balances.take(5).map((balance) {
          return PreviewTile(
            icon: AppIcons.assignmentOutlined,
            title: balance.workerName,
            subtitle:
                '${balance.toolName} • ${balance.balanceQuantity} ${balance.unit}',
          );
        }),
        if (balances.length > 5)
          MoreItemsNote(remainingCount: balances.length - 5),
      ],
    );
  }
}
