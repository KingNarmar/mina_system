import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';

class ReportOptionCard extends StatelessWidget {
  const ReportOptionCard({
    super.key,
    required this.report,
    required this.onTap,
  });

  final ReportOptionModel report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompactCard = constraints.maxWidth < 280;

        final padding = isCompactCard ? 16.0 : 20.0;
        final iconBoxSize = isCompactCard ? 44.0 : 52.0;
        final iconSize = isCompactCard ? 24.0 : 28.0;
        final horizontalGap = isCompactCard ? 12.0 : 16.0;
        final contentGap = isCompactCard ? 6.0 : 8.0;
        final actionGap = isCompactCard ? 10.0 : 16.0;

        return Card(
          elevation: 0,
          color: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.border),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: iconBoxSize,
                    height: iconBoxSize,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      report.icon,
                      color: AppColors.accent,
                      size: iconSize,
                    ),
                  ),
                  Gap(horizontalGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          report.title,
                          style: AppTextStyles.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Gap(contentGap),
                        Text(
                          report.description,
                          style: AppTextStyles.body,
                          maxLines: isCompactCard ? 3 : 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Gap(actionGap),
                        Text(
                          'Configure report',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
