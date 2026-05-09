import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/presentation/widgets/table/tools_table_header.dart';
import 'package:mina_system/features/tools/presentation/widgets/table/tools_table_row.dart';

class ToolsTable extends StatelessWidget {
  const ToolsTable({
    super.key,
    required this.tools,
    required this.showActions,
    this.onEdit,
    this.onDelete,
  });

  final List<ToolModel> tools;
  final bool showActions;
  final void Function(ToolModel tool)? onEdit;
  final void Function(ToolModel tool)? onDelete;

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
          ToolsTableHeader(showActions: showActions),
          const Divider(height: 1, color: AppColors.border),
          if (tools.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No tools found', style: AppTextStyles.body),
            )
          else
            ...tools.map((tool) {
              return ToolsTableRow(
                tool: tool,
                showActions: showActions,
                onEdit: onEdit,
                onDelete: onDelete,
              );
            }),
        ],
      ),
    );
  }
}
