import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:gap/gap.dart';

class ReportPreviewPlaceholder extends StatelessWidget {
  const ReportPreviewPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(20),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preview', style: AppTextStyles.title),
          Gap(12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.visibility_outlined, color: AppColors.textSecondary),
              Gap(12),
              Expanded(
                child: Text(
                  'Report results preview will appear here after connecting the filters to the custody transactions data.',
                  style: AppTextStyles.body,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
