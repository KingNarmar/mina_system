import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';
import 'package:mina_system/features/reports/presentation/functions/show_report_builder.dart';
import 'package:mina_system/features/reports/presentation/widgets/report_option_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  static const List<ReportOptionModel> _reports = [
    ReportOptionModel(
      type: ReportType.workerCustody,
      title: 'Worker Custody Report',
      description:
          'View all open custody balances and movements for a selected worker.',
      icon: Icons.person_search_outlined,
    ),
    ReportOptionModel(
      type: ReportType.toolHistory,
      title: 'Tool History Report',
      description:
          'Track the full custody movement history for a selected tool type.',
      icon: Icons.history_outlined,
    ),
    ReportOptionModel(
      type: ReportType.transactions,
      title: 'Transactions Report',
      description:
          'Review custody transactions by worker, tool, type, and date range.',
      icon: Icons.receipt_long_outlined,
    ),
    ReportOptionModel(
      type: ReportType.lostDamaged,
      title: 'Lost & Damaged Report',
      description:
          'Review tools closed as lost or damaged with notes and proof images.',
      icon: Icons.report_problem_outlined,
    ),
    ReportOptionModel(
      type: ReportType.lostDamagedApproval,
      title: 'Lost/Damaged Approval Report',
      description:
          'Print a formal approval document for lost or damaged tool cases before settlement.',
      icon: Icons.verified_user_outlined,
    ),
    ReportOptionModel(
      type: ReportType.toolSummary,
      title: 'Tool Summary Report',
      description:
          'Summarize issued, returned, lost, damaged, and open custody quantities.',
      icon: Icons.summarize_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < AppBreakpoints.tablet;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Reports Center', style: AppTextStyles.heading),
              const Gap(8),
              const Text(
                'Generate custody tracking reports based on workers, tools, transactions, and custody status.',
                style: AppTextStyles.body,
              ),
              const Gap(24),
              if (isMobile)
                const _ReportsList(reports: _reports)
              else
                _ReportsGrid(reports: _reports, width: constraints.maxWidth),
            ],
          ),
        );
      },
    );
  }
}

class _ReportsList extends StatelessWidget {
  const _ReportsList({required this.reports});

  final List<ReportOptionModel> reports;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: reports.map((report) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ReportOptionCard(
            report: report,
            onTap: () => showReportBuilder(context, report: report),
          ),
        );
      }).toList(),
    );
  }
}

class _ReportsGrid extends StatelessWidget {
  const _ReportsGrid({required this.reports, required this.width});

  final List<ReportOptionModel> reports;
  final double width;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = width < AppBreakpoints.desktop ? 2 : 3;

    return GridView.builder(
      itemCount: reports.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: width < AppBreakpoints.desktop ? 1.35 : 1.25,
      ),
      itemBuilder: (context, index) {
        final report = reports[index];

        return ReportOptionCard(
          report: report,
          onTap: () => showReportBuilder(context, report: report),
        );
      },
    );
  }
}
