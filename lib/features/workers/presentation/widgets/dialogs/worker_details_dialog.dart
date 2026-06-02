import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/record_accountability_section.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/core/theme/app_icons.dart';

class WorkerDetailsDialog extends StatelessWidget {
  const WorkerDetailsDialog({
    super.key,
    required this.worker,
    this.timezone,
    this.dateFormat,
  });

  final WorkerModel worker;
  final String? timezone;
  final String? dateFormat;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                    child: const Icon(AppIcons.worker, color: AppColors.accent),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Text(
                      worker.name,
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(AppIcons.close),
                    color: AppColors.textSecondary,
                    tooltip: 'Close',
                  ),
                ],
              ),
              const Gap(20),
              _WorkerDetailsInfoRow(label: 'HR Code', value: worker.hrCode),
              _WorkerDetailsInfoRow(
                label: 'Department',
                value: worker.department,
              ),
              _WorkerDetailsInfoRow(label: 'Job Title', value: worker.jobTitle),
              _WorkerDetailsInfoRow(
                label: 'Status',
                value: _formatStatus(worker.status),
              ),
              const Gap(16),
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
      ),
    );
  }

  String _formatStatus(String value) {
    final cleanValue = value.trim();

    if (cleanValue.isEmpty) {
      return 'Unknown';
    }

    return cleanValue[0].toUpperCase() + cleanValue.substring(1);
  }
}

class _WorkerDetailsInfoRow extends StatelessWidget {
  const _WorkerDetailsInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cleanValue = value.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Text(
              cleanValue.isEmpty ? '-' : cleanValue,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
