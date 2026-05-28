part of '../signed_reports_panel.dart';

class _SignedReportsList extends StatelessWidget {
  const _SignedReportsList({
    required this.state,
    required this.companyTimezone,
    required this.onOpenReport,
  });

  final SignedReportsState state;
  final String? companyTimezone;
  final void Function(SignedReportModel) onOpenReport;

  @override
  Widget build(BuildContext context) {
    if (state.isInitialLoading) {
      return const SignedReportsLoadingView();
    }

    if (!state.hasReports) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 42,
              color: AppColors.textSecondary,
            ),
            Gap(10),
            Text('No signed reports found.', style: AppTextStyles.body),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (state.isRefreshing) ...[
          const LinearProgressIndicator(minHeight: 2),
          const Gap(12),
        ],
        ...state.reports.map((report) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SignedReportCard(
              report: report,
              isOpening: state.isOpeningReport(report.id),
              timezone: companyTimezone,
              onOpen: () => onOpenReport(report),
            ),
          );
        }),
      ],
    );
  }
}
