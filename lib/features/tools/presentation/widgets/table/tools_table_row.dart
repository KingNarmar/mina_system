import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_state.dart';
import 'package:mina_system/features/tools/presentation/widgets/table/tools_table_cell.dart';

class ToolsTableRow extends StatelessWidget {
  const ToolsTableRow({
    super.key,
    required this.tool,
    required this.showActions,
    this.onViewDetails,
    this.onEdit,
    this.onDelete,
    this.onReactivate,
    this.onViewAuditHistory,
  });

  final ToolModel tool;
  final bool showActions;
  final void Function(ToolModel tool)? onViewDetails;
  final void Function(ToolModel tool)? onEdit;
  final void Function(ToolModel tool)? onDelete;
  final void Function(ToolModel tool)? onReactivate;
  final void Function(ToolModel tool)? onViewAuditHistory;

  @override
  Widget build(BuildContext context) {
    final toolCode = tool.toolCode;

    final isDeleting = context.select<ToolsCubit, bool>((cubit) {
      if (toolCode.isEmpty) {
        return false;
      }

      return cubit.state.isActionSubmitting(
        ToolsSubmissionKeys.delete(toolCode),
      );
    });

    final isReactivating = context.select<ToolsCubit, bool>((cubit) {
      if (toolCode.isEmpty) {
        return false;
      }

      return cubit.state.isActionSubmitting(
        ToolsSubmissionKeys.reactivate(toolCode),
      );
    });

    final isRowSubmitting = isDeleting || isReactivating;
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
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      if (onViewDetails != null)
                        IconButton(
                          onPressed: () {
                            onViewDetails!(tool);
                          },
                          icon: const Icon(Icons.info_outline),
                          color: AppColors.textSecondary,
                          tooltip: 'View Details',
                        ),
                      if (onViewAuditHistory != null)
                        IconButton(
                          onPressed: () {
                            onViewAuditHistory!(tool);
                          },
                          icon: const Icon(Icons.history_rounded),
                          color: AppColors.textSecondary,
                          tooltip: 'View Audit History',
                        ),
                      if (onEdit != null)
                        IconButton(
                          onPressed: isRowSubmitting
                              ? null
                              : () {
                                  onEdit!(tool);
                                },
                          icon: const Icon(Icons.edit_outlined),
                          color: AppColors.accent,
                          tooltip: 'Edit',
                        ),
                      if (onDelete != null)
                        IconButton(
                          onPressed: isRowSubmitting
                              ? null
                              : () {
                                  onDelete!(tool);
                                },
                          icon: isDeleting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.error,
                                  ),
                                )
                              : const Icon(Icons.delete_outline),
                          color: AppColors.error,
                          tooltip: 'Deactivate',
                        ),
                      if (onReactivate != null)
                        IconButton(
                          onPressed: isRowSubmitting
                              ? null
                              : () {
                                  onReactivate!(tool);
                                },
                          icon: isReactivating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.accent,
                                  ),
                                )
                              : const Icon(Icons.restore_outlined),
                          color: AppColors.accent,
                          tooltip: 'Reactivate',
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
