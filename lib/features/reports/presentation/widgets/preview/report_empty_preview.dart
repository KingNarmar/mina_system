import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';

class ReportEmptyPreview extends StatelessWidget {
  const ReportEmptyPreview({super.key, required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textSecondary),
        const Gap(12),
        Expanded(child: Text(message, style: AppTextStyles.body)),
      ],
    );
  }
}
