part of '../signed_reports_panel.dart';

class _SignedReportsHeader extends StatelessWidget {
  const _SignedReportsHeader({required this.state, required this.onRefresh});

  final SignedReportsState state;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final refreshLabel = state.isRefreshing
        ? 'Refreshing...'
        : state.isLoading
        ? 'Loading...'
        : 'Refresh';

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const SizedBox(
          width: 320,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Signed Reports', style: AppTextStyles.title),
              Gap(6),
              Text(
                'Search and open saved signed PDF evidence records.',
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
        Chip(
          avatar: const Icon(Icons.picture_as_pdf_outlined, size: 18),
          label: Text('${state.reports.length} saved'),
          backgroundColor: AppColors.accent.withValues(alpha: 0.08),
          side: BorderSide(color: AppColors.accent.withValues(alpha: 0.16)),
        ),
        OutlinedButton.icon(
          onPressed: state.isLoading ? null : onRefresh,
          icon: state.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh_outlined),
          label: Text(refreshLabel),
        ),
      ],
    );
  }
}
