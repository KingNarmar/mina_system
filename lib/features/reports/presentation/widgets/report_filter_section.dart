import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/reports/data/models/report_filter_model.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';

import 'filters/date_filter_tile.dart';
import 'filters/report_filter_visibility.dart';
import 'filters/tool_report_filter.dart';
import 'filters/transaction_type_report_filter.dart';
import 'filters/worker_report_filter.dart';

class ReportFilterSection extends StatelessWidget {
  const ReportFilterSection({
    super.key,
    required this.reportType,
    required this.filters,
    required this.onChanged,
  });

  final ReportType reportType;
  final ReportFilterModel filters;
  final ValueChanged<ReportFilterModel> onChanged;

  @override
  Widget build(BuildContext context) {
    final shouldShowWorker = ReportFilterVisibility.shouldShowWorkerFilter(
      reportType,
    );
    final shouldShowTool = ReportFilterVisibility.shouldShowToolFilter(
      reportType,
    );
    final shouldShowType = ReportFilterVisibility.shouldShowTypeFilter(
      reportType,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: Text('Filters', style: AppTextStyles.title)),
            TextButton(
              onPressed: filters.hasFilters
                  ? () => onChanged(const ReportFilterModel())
                  : null,
              child: const Text('Clear'),
            ),
          ],
        ),
        const Gap(12),
        if (shouldShowWorker) ...[
          WorkerReportFilter(filters: filters, onChanged: onChanged),
          const Gap(12),
        ],
        if (shouldShowTool) ...[
          ToolReportFilter(filters: filters, onChanged: onChanged),
          const Gap(12),
        ],
        if (shouldShowType) ...[
          TransactionTypeReportFilter(filters: filters, onChanged: onChanged),
          const Gap(12),
        ],
        DateFilterTile(
          title: 'Date From',
          selectedDate: filters.dateFrom,
          onDateSelected: (date) {
            onChanged(filters.copyWith(dateFrom: date));
          },
          onClear: () {
            onChanged(filters.copyWith(clearDateFrom: true));
          },
        ),
        const Gap(12),
        DateFilterTile(
          title: 'Date To',
          selectedDate: filters.dateTo,
          onDateSelected: (date) {
            onChanged(filters.copyWith(dateTo: date));
          },
          onClear: () {
            onChanged(filters.copyWith(clearDateTo: true));
          },
        ),
      ],
    );
  }
}
