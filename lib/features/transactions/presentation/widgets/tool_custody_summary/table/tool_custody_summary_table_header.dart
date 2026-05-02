import 'package:flutter/material.dart';
import 'package:mina_system/features/transactions/presentation/widgets/tool_custody_summary/table/tool_custody_summary_table_cell.dart';

class ToolCustodySummaryTableHeader extends StatelessWidget {
  const ToolCustodySummaryTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          ToolCustodySummaryTableHeaderCell(title: 'Tool', flex: 3),
          ToolCustodySummaryTableHeaderCell(title: 'Code', flex: 2),
          ToolCustodySummaryTableHeaderCell(title: 'Open', flex: 2),
          ToolCustodySummaryTableHeaderCell(title: 'Issued', flex: 2),
          ToolCustodySummaryTableHeaderCell(title: 'Returned', flex: 2),
          ToolCustodySummaryTableHeaderCell(title: 'Lost', flex: 2),
          ToolCustodySummaryTableHeaderCell(title: 'Damaged', flex: 2),
          ToolCustodySummaryTableHeaderCell(title: 'Moves', flex: 1),
        ],
      ),
    );
  }
}
