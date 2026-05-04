import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/custom_dropdown_form_field.dart';
import 'package:mina_system/core/widgets/searchable_selection_field.dart';
import 'package:mina_system/features/reports/data/models/report_filter_model.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_type_helpers.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';

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
    final shouldShowWorker = _shouldShowWorkerFilter(reportType);
    final shouldShowTool = _shouldShowToolFilter(reportType);
    final shouldShowType = reportType == ReportType.transactions;

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
          _WorkerReportFilter(filters: filters, onChanged: onChanged),
          const Gap(12),
        ],
        if (shouldShowTool) ...[
          _ToolReportFilter(filters: filters, onChanged: onChanged),
          const Gap(12),
        ],
        if (shouldShowType) ...[
          _TransactionTypeReportFilter(filters: filters, onChanged: onChanged),
          const Gap(12),
        ],
        _DateFilterTile(
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
        _DateFilterTile(
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

  bool _shouldShowWorkerFilter(ReportType type) {
    switch (type) {
      case ReportType.workerCustody:
      case ReportType.transactions:
      case ReportType.lostDamaged:
        return true;
      case ReportType.toolHistory:
      case ReportType.toolSummary:
        return false;
    }
  }

  bool _shouldShowToolFilter(ReportType type) {
    switch (type) {
      case ReportType.toolHistory:
      case ReportType.transactions:
      case ReportType.lostDamaged:
      case ReportType.toolSummary:
        return true;
      case ReportType.workerCustody:
        return false;
    }
  }
}

class _WorkerReportFilter extends StatelessWidget {
  const _WorkerReportFilter({required this.filters, required this.onChanged});

  final ReportFilterModel filters;
  final ValueChanged<ReportFilterModel> onChanged;

  @override
  Widget build(BuildContext context) {
    final workers = context.watch<WorkersCubit>().state.workers;

    return SearchableSelectionField<WorkerModel>(
      hint: 'Select Worker',
      items: workers,
      selectedItem: filters.worker,
      itemLabelBuilder: (worker) {
        return '${worker.name} (${worker.hrCode})';
      },
      searchMatcher: (worker, query) {
        final name = worker.name.trim().toLowerCase();
        final hrCode = worker.hrCode.trim().toLowerCase();
        final department = worker.department.trim().toLowerCase();
        final jobTitle = worker.jobTitle.trim().toLowerCase();

        return name.contains(query) ||
            hrCode.contains(query) ||
            department.contains(query) ||
            jobTitle.contains(query);
      },
      onItemSelected: (worker) {
        onChanged(filters.copyWith(worker: worker));
      },
    );
  }
}

class _ToolReportFilter extends StatelessWidget {
  const _ToolReportFilter({required this.filters, required this.onChanged});

  final ReportFilterModel filters;
  final ValueChanged<ReportFilterModel> onChanged;

  @override
  Widget build(BuildContext context) {
    final tools = context.watch<ToolsCubit>().state.tools;

    return SearchableSelectionField<ToolModel>(
      hint: 'Select Tool',
      items: tools,
      selectedItem: filters.tool,
      itemLabelBuilder: (tool) {
        return '${tool.toolName} (${tool.toolCode})';
      },
      searchMatcher: (tool, query) {
        final toolCode = tool.toolCode.trim().toLowerCase();
        final toolName = tool.toolName.trim().toLowerCase();
        final unit = tool.unit.trim().toLowerCase();
        final category = tool.category.trim().toLowerCase();

        return toolCode.contains(query) ||
            toolName.contains(query) ||
            unit.contains(query) ||
            category.contains(query);
      },
      onItemSelected: (tool) {
        onChanged(filters.copyWith(tool: tool));
      },
    );
  }
}

class _TransactionTypeReportFilter extends StatelessWidget {
  const _TransactionTypeReportFilter({
    required this.filters,
    required this.onChanged,
  });

  final ReportFilterModel filters;
  final ValueChanged<ReportFilterModel> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedLabel = filters.transactionType == null
        ? 'All types'
        : getTransactionTypeLabel(filters.transactionType!);

    return CustomDropdownFormField(
      hint: 'Transaction Type',
      value: selectedLabel,
      items: const ['All types', ...transactionTypeLabels],
      onChanged: (value) {
        if (value == null || value == 'All types') {
          onChanged(filters.copyWith(clearTransactionType: true));
          return;
        }

        onChanged(
          filters.copyWith(transactionType: getTransactionTypeFromLabel(value)),
        );
      },
    );
  }
}

class _DateFilterTile extends StatelessWidget {
  const _DateFilterTile({
    required this.title,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onClear,
  });

  final String title;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final selectedDateText = selectedDate == null
        ? 'Optional'
        : _formatDate(selectedDate!);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );

        if (pickedDate == null) {
          return;
        }

        onDateSelected(pickedDate);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined, color: AppColors.accent),
            const Gap(12),
            Expanded(child: Text(title, style: AppTextStyles.body)),
            const Gap(12),
            Text(
              selectedDateText,
              style: AppTextStyles.caption.copyWith(
                color: selectedDate == null
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (selectedDate != null) ...[
              const Gap(8),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onClear,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }
}
