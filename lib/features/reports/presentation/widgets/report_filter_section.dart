import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';

class ReportFilterSection extends StatelessWidget {
  const ReportFilterSection({super.key, required this.reportType});

  final ReportType reportType;

  @override
  Widget build(BuildContext context) {
    final filters = _getFilters(reportType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Filters', style: AppTextStyles.title),
        const SizedBox(height: 12),
        ...filters.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ReportFilterTile(filter: filter),
          );
        }),
      ],
    );
  }

  List<_ReportFilterInfo> _getFilters(ReportType type) {
    switch (type) {
      case ReportType.workerCustody:
        return const [
          _ReportFilterInfo(
            title: 'Worker',
            value: 'Select worker',
            icon: Icons.person_outline,
          ),
          _ReportFilterInfo(
            title: 'Date From',
            value: 'Optional',
            icon: Icons.calendar_month_outlined,
          ),
          _ReportFilterInfo(
            title: 'Date To',
            value: 'Optional',
            icon: Icons.event_outlined,
          ),
        ];
      case ReportType.toolHistory:
        return const [
          _ReportFilterInfo(
            title: 'Tool',
            value: 'Select tool type',
            icon: Icons.build_outlined,
          ),
          _ReportFilterInfo(
            title: 'Date From',
            value: 'Optional',
            icon: Icons.calendar_month_outlined,
          ),
          _ReportFilterInfo(
            title: 'Date To',
            value: 'Optional',
            icon: Icons.event_outlined,
          ),
        ];
      case ReportType.transactions:
        return const [
          _ReportFilterInfo(
            title: 'Worker',
            value: 'All workers',
            icon: Icons.person_outline,
          ),
          _ReportFilterInfo(
            title: 'Tool',
            value: 'All tools',
            icon: Icons.build_outlined,
          ),
          _ReportFilterInfo(
            title: 'Transaction Type',
            value: 'All types',
            icon: Icons.swap_horiz_outlined,
          ),
          _ReportFilterInfo(
            title: 'Date From',
            value: 'Optional',
            icon: Icons.calendar_month_outlined,
          ),
          _ReportFilterInfo(
            title: 'Date To',
            value: 'Optional',
            icon: Icons.event_outlined,
          ),
        ];
      case ReportType.lostDamaged:
        return const [
          _ReportFilterInfo(
            title: 'Status',
            value: 'Lost & Damaged',
            icon: Icons.report_problem_outlined,
          ),
          _ReportFilterInfo(
            title: 'Worker',
            value: 'All workers',
            icon: Icons.person_outline,
          ),
          _ReportFilterInfo(
            title: 'Tool',
            value: 'All tools',
            icon: Icons.build_outlined,
          ),
          _ReportFilterInfo(
            title: 'Date From',
            value: 'Optional',
            icon: Icons.calendar_month_outlined,
          ),
          _ReportFilterInfo(
            title: 'Date To',
            value: 'Optional',
            icon: Icons.event_outlined,
          ),
        ];
      case ReportType.toolSummary:
        return const [
          _ReportFilterInfo(
            title: 'Tool',
            value: 'All tools',
            icon: Icons.build_outlined,
          ),
          _ReportFilterInfo(
            title: 'Date From',
            value: 'Optional',
            icon: Icons.calendar_month_outlined,
          ),
          _ReportFilterInfo(
            title: 'Date To',
            value: 'Optional',
            icon: Icons.event_outlined,
          ),
        ];
    }
  }
}

class _ReportFilterTile extends StatelessWidget {
  const _ReportFilterTile({required this.filter});

  final _ReportFilterInfo filter;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(filter.icon, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(child: Text(filter.title, style: AppTextStyles.body)),
          const SizedBox(width: 12),
          Text(
            filter.value,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportFilterInfo {
  const _ReportFilterInfo({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;
}
