import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';
import 'package:mina_system/features/reports/presentation/widgets/report_filter_section.dart';
import 'package:mina_system/features/reports/presentation/widgets/report_preview_placeholder.dart';
import 'package:gap/gap.dart';

class ReportBuilderPanel extends StatelessWidget {
  const ReportBuilderPanel({super.key, required this.report});

  final ReportOptionModel report;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(20),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ReportBuilderHeader(report: report),
            const Gap(24),
            ReportFilterSection(reportType: report.type),
            const Gap(24),
            const ReportPreviewPlaceholder(),
            const Gap(24),
            _ReportBuilderActions(report: report),
          ],
        ),
      ),
    );
  }
}

class _ReportBuilderHeader extends StatelessWidget {
  const _ReportBuilderHeader({required this.report});

  final ReportOptionModel report;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(report.icon, color: AppColors.accent, size: 28),
        ),
        const Gap(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(report.title, style: AppTextStyles.title),
              const Gap(8),
              Text(report.description, style: AppTextStyles.body),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}

class _ReportBuilderActions extends StatelessWidget {
  const _ReportBuilderActions({required this.report});

  final ReportOptionModel report;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ),
        const Gap(12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('PDF Coming Soon'),
          ),
        ),
      ],
    );
  }
}
