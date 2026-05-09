import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';

class ReportOptionCard extends StatelessWidget {
  const ReportOptionCard({
    super.key,
    required this.report,
    required this.canGenerateReports,
    this.onTap,
  });

  final ReportOptionModel report;
  final bool canGenerateReports;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasFiniteHeight = constraints.maxHeight.isFinite;
        final isTightHeight = hasFiniteHeight && constraints.maxHeight < 190;
        final isCompactWidth = constraints.maxWidth < 280;
        final isCompactCard = isCompactWidth || isTightHeight;

        final padding = isTightHeight ? 12.0 : (isCompactCard ? 14.0 : 18.0);
        final iconBoxSize = isTightHeight
            ? 36.0
            : (isCompactCard ? 40.0 : 44.0);
        final iconSize = isTightHeight ? 20.0 : (isCompactCard ? 22.0 : 24.0);
        final horizontalGap = isCompactCard ? 10.0 : 12.0;
        final contentGap = isTightHeight ? 6.0 : 8.0;
        final actionGap = isTightHeight ? 6.0 : 10.0;
        final descriptionMaxLines = isTightHeight ? 2 : 3;

        return Opacity(
          opacity: canGenerateReports ? 1 : 0.72,
          child: Card(
            margin: EdgeInsets.zero,
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
                child: hasFiniteHeight
                    ? _FiniteHeightCardContent(
                        report: report,
                        canGenerateReports: canGenerateReports,
                        iconBoxSize: iconBoxSize,
                        iconSize: iconSize,
                        horizontalGap: horizontalGap,
                        contentGap: contentGap,
                        actionGap: actionGap,
                        descriptionMaxLines: descriptionMaxLines,
                      )
                    : _NaturalHeightCardContent(
                        report: report,
                        canGenerateReports: canGenerateReports,
                        iconBoxSize: iconBoxSize,
                        iconSize: iconSize,
                        horizontalGap: horizontalGap,
                        contentGap: contentGap,
                        actionGap: actionGap,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FiniteHeightCardContent extends StatelessWidget {
  const _FiniteHeightCardContent({
    required this.report,
    required this.canGenerateReports,
    required this.iconBoxSize,
    required this.iconSize,
    required this.horizontalGap,
    required this.contentGap,
    required this.actionGap,
    required this.descriptionMaxLines,
  });

  final ReportOptionModel report;
  final bool canGenerateReports;
  final double iconBoxSize;
  final double iconSize;
  final double horizontalGap;
  final double contentGap;
  final double actionGap;
  final int descriptionMaxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ReportCardHeader(
          report: report,
          iconBoxSize: iconBoxSize,
          iconSize: iconSize,
          horizontalGap: horizontalGap,
        ),
        Gap(contentGap),
        Expanded(
          child: Text(
            report.description,
            style: AppTextStyles.body,
            maxLines: descriptionMaxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Gap(actionGap),
        _ReportCardActionText(canGenerateReports: canGenerateReports),
      ],
    );
  }
}

class _NaturalHeightCardContent extends StatelessWidget {
  const _NaturalHeightCardContent({
    required this.report,
    required this.canGenerateReports,
    required this.iconBoxSize,
    required this.iconSize,
    required this.horizontalGap,
    required this.contentGap,
    required this.actionGap,
  });

  final ReportOptionModel report;
  final bool canGenerateReports;
  final double iconBoxSize;
  final double iconSize;
  final double horizontalGap;
  final double contentGap;
  final double actionGap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _ReportCardHeader(
          report: report,
          iconBoxSize: iconBoxSize,
          iconSize: iconSize,
          horizontalGap: horizontalGap,
        ),
        Gap(contentGap),
        Text(
          report.description,
          style: AppTextStyles.body,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        Gap(actionGap),
        _ReportCardActionText(canGenerateReports: canGenerateReports),
      ],
    );
  }
}

class _ReportCardHeader extends StatelessWidget {
  const _ReportCardHeader({
    required this.report,
    required this.iconBoxSize,
    required this.iconSize,
    required this.horizontalGap,
  });

  final ReportOptionModel report;
  final double iconBoxSize;
  final double iconSize;
  final double horizontalGap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: iconBoxSize,
          height: iconBoxSize,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(report.icon, color: AppColors.accent, size: iconSize),
        ),
        Gap(horizontalGap),
        Expanded(
          child: Text(
            report.title,
            style: AppTextStyles.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ReportCardActionText extends StatelessWidget {
  const _ReportCardActionText({required this.canGenerateReports});

  final bool canGenerateReports;

  @override
  Widget build(BuildContext context) {
    return Text(
      canGenerateReports ? 'Configure report' : 'View only',
      style: AppTextStyles.body.copyWith(
        color: canGenerateReports ? AppColors.accent : AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
