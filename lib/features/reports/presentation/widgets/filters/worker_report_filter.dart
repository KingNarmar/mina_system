import 'package:flutter/material.dart';
import 'package:mina_system/core/widgets/searchable_selection_field.dart';
import 'package:mina_system/features/reports/data/models/report_filter_model.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';

class WorkerReportFilter extends StatelessWidget {
  const WorkerReportFilter({
    super.key,
    required this.filters,
    required this.workers,
    required this.onChanged,
  });

  final ReportFilterModel filters;
  final List<WorkerModel> workers;
  final ValueChanged<ReportFilterModel> onChanged;

  @override
  Widget build(BuildContext context) {
    return SearchableSelectionField<WorkerModel>(
      hint: 'Select Worker',
      items: workers,
      selectedItem: filters.worker,
      itemLabelBuilder: (worker) {
        final statusSuffix = worker.status.trim().toLowerCase() == 'inactive'
            ? ' - Inactive'
            : '';

        return '${worker.name} (${worker.hrCode})$statusSuffix';
      },
      searchMatcher: (worker, query) {
        final name = worker.name.trim().toLowerCase();
        final hrCode = worker.hrCode.trim().toLowerCase();
        final department = worker.department.trim().toLowerCase();
        final jobTitle = worker.jobTitle.trim().toLowerCase();
        final status = worker.status.trim().toLowerCase();

        return name.contains(query) ||
            hrCode.contains(query) ||
            department.contains(query) ||
            jobTitle.contains(query) ||
            status.contains(query);
      },
      onItemSelected: (worker) {
        onChanged(filters.copyWith(worker: worker));
      },
    );
  }
}
