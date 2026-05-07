import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/widgets/searchable_selection_field.dart';
import 'package:mina_system/features/reports/data/models/report_filter_model.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';

class WorkerReportFilter extends StatelessWidget {
  const WorkerReportFilter({
    super.key,
    required this.filters,
    required this.onChanged,
  });

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
