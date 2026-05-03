import 'package:flutter/material.dart';
import 'package:mina_system/features/tools/presentation/widgets/table/tools_table_cell.dart';

class ToolsTableHeader extends StatelessWidget {
  const ToolsTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          ToolsTableHeaderCell(title: 'Tool Code', flex: 2),
          ToolsTableHeaderCell(title: 'Tool Name', flex: 3),
          ToolsTableHeaderCell(title: 'Unit', flex: 1),
          ToolsTableHeaderCell(title: 'Category', flex: 2),
          ToolsTableHeaderCell(title: 'Actions', flex: 2),
        ],
      ),
    );
  }
}
