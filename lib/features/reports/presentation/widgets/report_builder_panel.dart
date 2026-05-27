import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/utils/app_error_message.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_cubit.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_state.dart';
import 'package:mina_system/features/reports/data/models/report_filter_model.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';
import 'package:mina_system/features/reports/presentation/functions/show_report_pdf_preview.dart';
import 'package:mina_system/features/reports/presentation/widgets/report_filter_section.dart';
import 'package:mina_system/features/reports/presentation/widgets/report_preview_section.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/data/repo/tools_repo.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/data/repo/workers_repo.dart';

class ReportBuilderPanel extends StatefulWidget {
  const ReportBuilderPanel({
    super.key,
    required this.report,
    required this.companyId,
    required this.canGenerateReports,
  });

  final ReportOptionModel report;
  final String companyId;
  final bool canGenerateReports;

  @override
  State<ReportBuilderPanel> createState() => _ReportBuilderPanelState();
}

class _ReportBuilderPanelState extends State<ReportBuilderPanel> {
  final WorkersRepo _workersRepo = WorkersRepo();
  final ToolsRepo _toolsRepo = ToolsRepo();

  ReportFilterModel _filters = const ReportFilterModel();
  List<WorkerModel> _reportWorkers = const [];
  List<ToolModel> _reportTools = const [];
  bool _isLoadingFilterOptions = true;
  String? _filterOptionsError;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadReportFilterOptions);
  }

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
            if (_isLoadingFilterOptions)
              const _ReportFilterOptionsLoading()
            else if (_filterOptionsError != null)
              _ReportFilterOptionsError(
                message: _filterOptionsError!,
                onRetry: _loadReportFilterOptions,
              )
            else
              ReportFilterSection(
                reportType: widget.report.type,
                filters: _filters,
                workers: _reportWorkers,
                tools: _reportTools,
                onChanged: _onFiltersChanged,
              ),
            const Gap(24),
            ReportPreviewSection(
              reportType: widget.report.type,
              filters: _filters,
            ),
            const Gap(24),
            _ReportBuilderActions(
              report: widget.report,
              filters: _filters,
              canGenerateReports: widget.canGenerateReports,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadReportFilterOptions() async {
    setState(() {
      _isLoadingFilterOptions = true;
      _filterOptionsError = null;
    });

    try {
      final companyId = widget.companyId;

      final workersFuture = _workersRepo.getWorkers(
        companyId: companyId,
        status: null,
      );

      final toolsFuture = _toolsRepo.getTools(
        companyId: companyId,
        status: null,
      );

      await Future.wait([workersFuture, toolsFuture]);

      final workers = await workersFuture;
      final tools = await toolsFuture;

      if (!mounted) {
        return;
      }

      setState(() {
        _reportWorkers = workers;
        _reportTools = tools;
        _isLoadingFilterOptions = false;
        _filterOptionsError = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingFilterOptions = false;
        _filterOptionsError = AppErrorMessage.fromError(
          error,
          fallback: 'Unable to load report filters. Please try again.',
        );
      });
    }
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

class _ReportFilterOptionsLoading extends StatelessWidget {
  const _ReportFilterOptionsLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          Gap(12),
          Expanded(
            child: Text('Loading report filters...', style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }
}

class _ReportFilterOptionsError extends StatelessWidget {
  const _ReportFilterOptionsError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: AppTextStyles.body),
          const Gap(12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportBuilderActions extends StatelessWidget {
  const _ReportBuilderActions({
    required this.report,
    required this.filters,
    required this.canGenerateReports,
  });

  final ReportOptionModel report;
  final ReportFilterModel filters;
  final bool canGenerateReports;

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
            onPressed: canGenerateReports
                ? () {
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
                      companyId: companySettingsState.profile.id,
                      reportType: report.type,
                      filters: filters,
                      transactions: transactions,
                      companyProfile: companySettingsState.profile,
                      reportSettings: companySettingsState.reportSettings,
                      documentTemplates: companySettingsState.documentTemplates,
                    );
                  }
                : null,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Preview PDF'),
          ),
        ),
      ],
    );
  }
}
