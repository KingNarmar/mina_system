import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';

class ReportSettingSwitch extends StatelessWidget {
  const ReportSettingSwitch({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final borderColor = value
        ? AppColors.accent.withValues(alpha: 0.35)
        : AppColors.border;

    final iconBackgroundColor = value
        ? AppColors.accent.withValues(alpha: 0.10)
        : AppColors.background;

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 104),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: value
                        ? AppColors.accent.withValues(alpha: 0.14)
                        : AppColors.border,
                  ),
                ),
                child: Icon(
                  icon,
                  color: value ? AppColors.accent : AppColors.textSecondary,
                  size: 19,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Switch(
                    value: value,
                    activeThumbColor: AppColors.accent,
                    onChanged: onChanged,
                  ),
                  Text(
                    value ? 'On' : 'Off',
                    style: AppTextStyles.caption.copyWith(
                      color: value ? AppColors.accent : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
