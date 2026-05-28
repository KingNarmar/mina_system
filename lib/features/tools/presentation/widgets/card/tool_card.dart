import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/record_accountability_section.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_state.dart';
import 'package:mina_system/features/tools/presentation/widgets/card/tool_info_row.dart';

class ToolCard extends StatelessWidget {
  const ToolCard({
    super.key,
    required this.tool,
    this.onEdit,
    this.onDelete,
    this.onReactivate,
    this.onViewAuditHistory,
    this.timezone,
    this.dateFormat,
  });

  final ToolModel tool;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReactivate;
  final VoidCallback? onViewAuditHistory;
  final String? timezone;
  final String? dateFormat;

  @override
  Widget build(BuildContext context) {
    final showActions =
        onEdit != null ||
        onDelete != null ||
        onReactivate != null ||
        onViewAuditHistory != null;
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
    return Card(
      elevation: 0,
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                  child: const Icon(
                    Icons.build_outlined,
                    color: AppColors.accent,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    tool.toolName,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (showActions) ...[
                  if (onViewAuditHistory != null)
                    IconButton(
                      onPressed: onViewAuditHistory,
                      icon: const Icon(Icons.history_rounded),
                      color: AppColors.textSecondary,
                      tooltip: 'View Audit History',
                    ),
                  if (onEdit != null)
                    IconButton(
                      onPressed: isRowSubmitting ? null : onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      color: AppColors.accent,
                      tooltip: 'Edit',
                    ),
                  if (onDelete != null)
                    IconButton(
                      onPressed: isRowSubmitting ? null : onDelete,
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
                      onPressed: isRowSubmitting ? null : onReactivate,
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
              ],
            ),
            const Gap(16),
            ToolInfoRow(label: 'Tool Code', value: tool.toolCode),
            ToolInfoRow(label: 'Unit', value: tool.unit),
            ToolInfoRow(label: 'Category', value: tool.category),
            const Gap(12),
            RecordAccountabilitySection(
              createdBy: tool.createdByDisplayName,
              updatedBy: tool.updatedByDisplayName,
              createdAt: tool.createdAt,
              updatedAt: tool.updatedAt,
              timezone: timezone,
              dateFormat: dateFormat,
            ),
          ],
        ),
      ),
    );
  }
}
