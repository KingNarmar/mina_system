import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/presentation/widgets/card/worker_info_row.dart';

class WorkerCard extends StatelessWidget {
  const WorkerCard({
    super.key,
    required this.worker,
    this.onEdit,
    this.onDelete,
    this.onReactivate,
  });

  final WorkerModel worker;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReactivate;

  @override
  Widget build(BuildContext context) {
    final showActions =
        onEdit != null || onDelete != null || onReactivate != null;

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
                    Icons.person_outline,
                    color: AppColors.accent,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    worker.name,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (showActions) ...[
                  if (onEdit != null)
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      color: AppColors.accent,
                      tooltip: 'Edit',
                    ),
                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      color: AppColors.error,
                      tooltip: 'Deactivate',
                    ),
                  if (onReactivate != null)
                    IconButton(
                      onPressed: onReactivate,
                      icon: const Icon(Icons.restore_outlined),
                      color: AppColors.accent,
                      tooltip: 'Reactivate',
                    ),
                ],
              ],
            ),
            const Gap(16),
            WorkerInfoRow(label: 'HR Code', value: worker.hrCode),
            WorkerInfoRow(label: 'Department', value: worker.department),
            WorkerInfoRow(label: 'Job Title', value: worker.jobTitle),
          ],
        ),
      ),
    );
  }
}
