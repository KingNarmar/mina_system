import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/features/transactions/data/models/tool_custody_summary_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/format_quantity.dart';
import 'package:mina_system/features/transactions/presentation/widgets/tool_custody_summary/table/tool_custody_summary_table_cell.dart';

class ToolCustodySummaryTableRow extends StatelessWidget {
  const ToolCustodySummaryTableRow({super.key, required this.summary});

  final ToolCustodySummaryModel summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              ToolCustodySummaryTableBodyCell(value: summary.toolName, flex: 3),
              ToolCustodySummaryTableBodyCell(value: summary.toolCode, flex: 2),
              ToolCustodySummaryTableBodyCell(
                value:
                    '${formatQuantity(summary.openCustodyQuantity)} ${summary.unit}',
                flex: 2,
              ),
              ToolCustodySummaryTableBodyCell(
                value:
                    '${formatQuantity(summary.issuedQuantity)} ${summary.unit}',
                flex: 2,
              ),
              ToolCustodySummaryTableBodyCell(
                value:
                    '${formatQuantity(summary.returnedQuantity)} ${summary.unit}',
                flex: 2,
              ),
              ToolCustodySummaryTableBodyCell(
                value:
                    '${formatQuantity(summary.lostQuantity)} ${summary.unit}',
                flex: 2,
              ),
              ToolCustodySummaryTableBodyCell(
                value:
                    '${formatQuantity(summary.damagedQuantity)} ${summary.unit}',
                flex: 2,
              ),
              ToolCustodySummaryTableBodyCell(
                value: summary.totalMovements.toString(),
                flex: 1,
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}
