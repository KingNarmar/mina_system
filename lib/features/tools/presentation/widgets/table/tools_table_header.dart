import 'package:flutter/material.dart';
import 'package:mina_system/features/tools/presentation/widgets/table/tools_table_cell.dart';

class ToolsTableHeader extends StatelessWidget {
  const ToolsTableHeader({super.key, required this.showActions});

  final bool showActions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          const ToolsTableHeaderCell(title: 'Tool Code', flex: 2),
          const ToolsTableHeaderCell(title: 'Tool Name', flex: 3),
          const ToolsTableHeaderCell(title: 'Unit', flex: 1),
          const ToolsTableHeaderCell(title: 'Category', flex: 2),
          if (showActions)
            const ToolsTableHeaderCell(title: 'Actions', flex: 2),
        ],
      ),
    );
  }
}
