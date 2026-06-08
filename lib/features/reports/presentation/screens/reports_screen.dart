import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/app_mode/app_mode.dart';
import 'package:mina_system/core/app_mode/app_mode_scope.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_icons.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';
import 'package:mina_system/features/reports/presentation/functions/show_report_builder.dart';
import 'package:mina_system/features/reports/presentation/widgets/report_option_card.dart';
import 'package:mina_system/features/reports/presentation/widgets/signed_reports_panel.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  static const List<ReportOptionModel> _reports = [
    ReportOptionModel(
      type: ReportType.workerCustody,
      title: 'Worker Custody Report',
      description:
          'View all open custody balances and movements for a selected worker.',
      icon: AppIcons.personSearchOutlined,
    ),
    ReportOptionModel(
      type: ReportType.toolHistory,
      title: 'Tool History Report',
      description:
          'Track the full custody movement history for a selected tool type.',
      icon: AppIcons.historyOutlined,
    ),
    ReportOptionModel(
      type: ReportType.transactions,
      title: 'Transactions Report',
      description:
          'Review custody transactions by worker, tool, type, and date range.',
      icon: AppIcons.receiptLongOutlined,
    ),
    ReportOptionModel(
      type: ReportType.lostDamaged,
      title: 'Lost & Damaged Report',
      description:
          'Review tools closed as lost or damaged with notes and proof images.',
      icon: AppIcons.reportProblemOutlined,
    ),
    ReportOptionModel(
      type: ReportType.lostDamagedApproval,
      title: 'Lost/Damaged Approval Report',
      description:
          'Print a formal approval document for lost or damaged tool cases before settlement.',
      icon: AppIcons.verifiedUser,
    ),
    ReportOptionModel(
      type: ReportType.toolSummary,
      title: 'Tool Summary Report',
      description:
          'Summarize issued, returned, lost, damaged, and open custody quantities.',
      icon: AppIcons.summarizeOutlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final appMode = AppModeScope.maybeOf(context) ?? AppMode.live;
    final isDemo = appMode.isDemo;

    final currentRole = context.currentUserRole;
    final currentCompany = context.currentCompany;
    final currentCompanyId = currentCompany?.id;
    final currentCompanyTimezone = currentCompany?.timezone;

    final canViewReports = CompanyRolePermissions.canViewReports(currentRole);
    final canGenerateReports = CompanyRolePermissions.canGenerateReports(
      currentRole,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaSize = MediaQuery.sizeOf(context);
        final isMobile = mediaSize.shortestSide < AppBreakpoints.tablet;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Reports Center', style: AppTextStyles.heading),
              const Gap(8),
              Text(
                canGenerateReports
                    ? 'Generate custody tracking reports based on workers, tools, transactions, and custody status.'
                    : 'You can view available report types, but your current role cannot generate reports.',
                style: AppTextStyles.body,
              ),
              if (isDemo) ...[const Gap(16), const _DemoReportsBanner()],
              const Gap(24),
              if (isMobile)
                _ReportsList(
                  reports: _reports,
                  canGenerateReports: canGenerateReports,
                )
              else
                _ReportsGrid(
                  reports: _reports,
                  width: constraints.maxWidth,
                  canGenerateReports: canGenerateReports,
                ),
              if (canViewReports && currentCompanyId != null) ...[
                const Gap(28),
                SignedReportsPanel(
                  companyId: currentCompanyId,
                  companyTimezone: currentCompanyTimezone,
                  isDemo: isDemo,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DemoReportsBanner extends StatelessWidget {
  const _DemoReportsBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(AppIcons.info, color: AppColors.warning, size: 22),
          const Gap(10),
          Expanded(
            child: Text(
              'Demo mode can generate, sign, and save reports locally on this device. '
              'No cloud upload or Supabase write is performed.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportsList extends StatelessWidget {
  const _ReportsList({required this.reports, required this.canGenerateReports});

  final List<ReportOptionModel> reports;
  final bool canGenerateReports;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: reports.map((report) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ReportOptionCard(
            report: report,
            canGenerateReports: canGenerateReports,
            onTap: canGenerateReports
                ? () {
                    showReportBuilder(
                      context,
                      report: report,
                      canGenerateReports: canGenerateReports,
                    );
                  }
                : null,
          ),
        );
      }).toList(),
    );
  }
}

class _ReportsGrid extends StatelessWidget {
  const _ReportsGrid({
    required this.reports,
    required this.width,
    required this.canGenerateReports,
  });

  final List<ReportOptionModel> reports;
  final double width;
  final bool canGenerateReports;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = width < 780 ? 2 : 3;
    final cardHeight = width < 900 ? 190.0 : 180.0;

    return GridView.builder(
      itemCount: reports.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: cardHeight,
      ),
      itemBuilder: (context, index) {
        final report = reports[index];

        return ReportOptionCard(
          report: report,
          canGenerateReports: canGenerateReports,
          onTap: canGenerateReports
              ? () {
                  showReportBuilder(
                    context,
                    report: report,
                    canGenerateReports: canGenerateReports,
                  );
                }
              : null,
        );
      },
    );
  }
}
