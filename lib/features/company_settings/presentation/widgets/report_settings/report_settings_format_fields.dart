import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';

import 'report_settings_form_helpers.dart';
import 'package:mina_system/core/theme/app_icons.dart';

class ReportSettingsFormatFields extends StatelessWidget {
  const ReportSettingsFormatFields({
    super.key,
    required this.timezoneController,
    required this.dateFormatController,
    required this.timeFormatController,
  });

  final TextEditingController timezoneController;
  final TextEditingController dateFormatController;
  final TextEditingController timeFormatController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideLayout = constraints.maxWidth >= 900;

        if (isWideLayout) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ReportFormatField(
                  label: 'Default Timezone',
                  helperText: 'Used as the default timezone for reports.',
                  controller: timezoneController,
                  icon: AppIcons.publicRounded,
                ),
              ),
              const Gap(12),
              Expanded(
                child: _ReportFormatField(
                  label: 'Date Format',
                  helperText: 'Example: dd/MM/yyyy',
                  controller: dateFormatController,
                  icon: AppIcons.calendarMonthOutlined,
                ),
              ),
              const Gap(12),
              Expanded(
                child: _ReportFormatField(
                  label: 'Time Format',
                  helperText: 'Example: HH:mm',
                  controller: timeFormatController,
                  icon: AppIcons.schedule,
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ReportFormatField(
              label: 'Default Timezone',
              helperText: 'Used as the default timezone for reports.',
              controller: timezoneController,
              icon: AppIcons.publicRounded,
            ),
            const Gap(12),
            _ReportFormatField(
              label: 'Date Format',
              helperText: 'Example: dd/MM/yyyy',
              controller: dateFormatController,
              icon: AppIcons.calendarMonthOutlined,
            ),
            const Gap(12),
            _ReportFormatField(
              label: 'Time Format',
              helperText: 'Example: HH:mm',
              controller: timeFormatController,
              icon: AppIcons.schedule,
            ),
          ],
        );
      },
    );
  }
}

class _ReportFormatField extends StatelessWidget {
  const _ReportFormatField({
    required this.label,
    required this.helperText,
    required this.controller,
    required this.icon,
  });

  final String label;
  final String helperText;
  final TextEditingController controller;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Gap(6),
        CustomTextFormField(
          hint: label,
          controller: controller,
          icon: Icon(icon, size: 18, color: AppColors.textSecondary),
          validator: ReportSettingsFormHelpers.validateRequired,
          fillColor: AppColors.card,
          borderColor: AppColors.border,
          focusedBorderColor: AppColors.accent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          hintStyle: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
          textStyle: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(6),
        Text(
          helperText,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
