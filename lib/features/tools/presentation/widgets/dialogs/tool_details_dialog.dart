import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/record_accountability_section.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/core/theme/app_icons.dart';

class ToolDetailsDialog extends StatelessWidget {
  const ToolDetailsDialog({
    super.key,
    required this.tool,
    this.timezone,
    this.dateFormat,
  });

  final ToolModel tool;
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
                    child: const Icon(AppIcons.tool, color: AppColors.accent),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Text(
                      tool.toolName,
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
              _ToolDetailsInfoRow(label: 'Tool Code', value: tool.toolCode),
              _ToolDetailsInfoRow(label: 'Unit', value: tool.unit),
              _ToolDetailsInfoRow(label: 'Category', value: tool.category),
              _ToolDetailsInfoRow(
                label: 'Status',
                value: _formatStatus(tool.status),
              ),
              const Gap(16),
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

class _ToolDetailsInfoRow extends StatelessWidget {
  const _ToolDetailsInfoRow({required this.label, required this.value});

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
