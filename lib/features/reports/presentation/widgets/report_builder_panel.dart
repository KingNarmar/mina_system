import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_cubit.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_state.dart';
import 'package:mina_system/features/reports/data/models/report_filter_model.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';
import 'package:mina_system/features/reports/presentation/functions/show_report_pdf_preview.dart';
import 'package:mina_system/features/reports/presentation/widgets/report_filter_section.dart';
import 'package:mina_system/features/reports/presentation/widgets/report_preview_section.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';

class ReportBuilderPanel extends StatefulWidget {
  const ReportBuilderPanel({super.key, required this.report});

  final ReportOptionModel report;

  @override
  State<ReportBuilderPanel> createState() => _ReportBuilderPanelState();
}

class _ReportBuilderPanelState extends State<ReportBuilderPanel> {
  ReportFilterModel _filters = const ReportFilterModel();

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
            _ReportBuilderHeader(report: widget.report),
            const Gap(24),
            ReportFilterSection(
              reportType: widget.report.type,
              filters: _filters,
              onChanged: _onFiltersChanged,
            ),
            const Gap(24),
            ReportPreviewSection(
              reportType: widget.report.type,
              filters: _filters,
            ),
            const Gap(24),
            _ReportBuilderActions(report: widget.report, filters: _filters),
          ],
        ),
      ),
    );
  }

  void _onFiltersChanged(ReportFilterModel filters) {
    setState(() {
      _filters = filters;
    });
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
  const _ReportBuilderActions({required this.report, required this.filters});

  final ReportOptionModel report;
  final ReportFilterModel filters;

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
            onPressed: () {
              final transactions = context
                  .read<TransactionsCubit>()
                  .state
                  .transactions;
              final companySettingsState = context
                  .read<CompanySettingsCubit>()
                  .state;

              if (companySettingsState is! CompanySettingsLoaded) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Company settings are still loading. Please try again.',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                return;
              }
              showReportPdfPreview(
                context,
                reportType: report.type,
                filters: filters,
                transactions: transactions,
                companyProfile: companySettingsState.profile,
                reportSettings: companySettingsState.reportSettings,
              );
            },
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Preview PDF'),
          ),
        ),
      ],
    );
  }
}
