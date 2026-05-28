import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/record_accountability_section.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_state.dart';
import 'package:mina_system/features/workers/presentation/widgets/card/worker_info_row.dart';

class WorkerCard extends StatelessWidget {
  const WorkerCard({
    super.key,
    required this.worker,
    this.onEdit,
    this.onDelete,
    this.onReactivate,
    this.onViewAuditHistory,
    this.timezone,
    this.dateFormat,
  });

  final WorkerModel worker;
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
    final workerId = worker.id ?? '';

    final isDeleting = context.select<WorkersCubit, bool>((cubit) {
      if (workerId.isEmpty) {
        return false;
      }

      return cubit.state.isActionSubmitting(
        WorkersSubmissionKeys.delete(workerId),
      );
    });

    final isReactivating = context.select<WorkersCubit, bool>((cubit) {
      if (workerId.isEmpty) {
        return false;
      }

      return cubit.state.isActionSubmitting(
        WorkersSubmissionKeys.reactivate(workerId),
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
            WorkerInfoRow(label: 'HR Code', value: worker.hrCode),
            WorkerInfoRow(label: 'Department', value: worker.department),
            WorkerInfoRow(label: 'Job Title', value: worker.jobTitle),
            const Gap(12),
            RecordAccountabilitySection(
              createdBy: worker.createdByDisplayName,
              updatedBy: worker.updatedByDisplayName,
              createdAt: worker.createdAt,
              updatedAt: worker.updatedAt,
              timezone: timezone,
              dateFormat: dateFormat,
            ),
          ],
        ),
      ),
    );
  }
}
