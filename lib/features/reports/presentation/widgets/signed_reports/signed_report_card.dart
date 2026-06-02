part of '../signed_reports_panel.dart';

class _SignedReportCard extends StatelessWidget {
  const _SignedReportCard({
    required this.report,
    required this.isOpening,
    required this.timezone,
    required this.onOpen,
  });

  final SignedReportModel report;
  final bool isOpening;
  final String? timezone;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 720;

          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(report.reportNumber, style: AppTextStyles.title),
              const Gap(6),
              Text(report.reportTypeLabel, style: AppTextStyles.body),
              const Gap(12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: AppIcons.worker,
                    text: report.workerNameSnapshot?.trim().isNotEmpty == true
                        ? report.workerNameSnapshot!
                        : report.signedByName,
                  ),
                  if (report.workerHrCodeSnapshot?.trim().isNotEmpty == true)
                    _InfoChip(
                      icon: AppIcons.badgeOutlined,
                      text: report.workerHrCodeSnapshot!,
                    ),
                  if (report.transactionCodeSnapshot?.trim().isNotEmpty == true)
                    _InfoChip(
                      icon: AppIcons.receiptLongOutlined,
                      text: report.transactionCodeSnapshot!,
                    ),
                  _InfoChip(
                    icon: AppIcons.eventOutlined,
                    text: _formatDateTime(report.signedAt),
                  ),
                  _InfoChip(
                    icon: AppIcons.dataObjectOutlined,
                    text: _formatFileSize(report.fileSize),
                  ),
                ],
              ),
              const Gap(10),
              Text(
                'Created by ${report.createdByDisplayName}',
                style: AppTextStyles.caption,
              ),
            ],
          );

          final openButton = ElevatedButton.icon(
            onPressed: isOpening ? null : onOpen,
            icon: isOpening
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(AppIcons.openInNewOutlined),
            label: Text(isOpening ? 'Opening...' : 'Open PDF'),
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [details, const Gap(14), openButton],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: details),
              const Gap(16),
              openButton,
            ],
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return CompanyDateTimeFormatter.formatDateTimeWithMonthName(
      dateTime,
      timezone: timezone,
      includeTimezone: true,
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
      backgroundColor: AppColors.card,
      side: const BorderSide(color: AppColors.border),
    );
  }
}
