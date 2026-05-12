import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/presentation/widgets/table/tools_table_cell.dart';

class ToolsTableRow extends StatelessWidget {
  const ToolsTableRow({
    super.key,
    required this.tool,
    required this.showActions,
    this.onEdit,
    this.onDelete,
  });

  final ToolModel tool;
  final bool showActions;
  final void Function(ToolModel tool)? onEdit;
  final void Function(ToolModel tool)? onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              ToolsTableBodyCell(value: tool.toolCode, flex: 2),
              ToolsTableBodyCell(value: tool.toolName, flex: 3),
              ToolsTableBodyCell(value: tool.unit, flex: 1),
              ToolsTableBodyCell(value: tool.category, flex: 2),
              if (showActions)
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      if (onEdit != null)
                        IconButton(
                          onPressed: () {
                            onEdit!(tool);
                          },
                          icon: const Icon(Icons.edit_outlined),
                          color: AppColors.accent,
                          tooltip: 'Edit',
                        ),
                      if (onDelete != null)
                        IconButton(
                          onPressed: () {
                            onDelete!(tool);
                          },
                          icon: const Icon(Icons.delete_outline),
                          color: AppColors.error,
                          tooltip: 'Deactivate',
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}
