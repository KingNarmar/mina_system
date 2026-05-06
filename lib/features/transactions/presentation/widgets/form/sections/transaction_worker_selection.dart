import 'package:flutter/material.dart';
import 'package:mina_system/core/widgets/searchable_selection_field.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_form_helpers.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_form_validators.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';

class TransactionWorkerSelection extends StatelessWidget {
  const TransactionWorkerSelection({
    super.key,
    required this.workers,
    required this.selectedWorker,
    required this.onSelected,
  });

  final List<WorkerModel> workers;
  final WorkerModel? selectedWorker;
  final ValueChanged<WorkerModel> onSelected;

  @override
  Widget build(BuildContext context) {
    return SearchableSelectionField<WorkerModel>(
      hint: 'Search Worker by HR Code or Name',
      items: workers,
      selectedItem: selectedWorker,
      itemLabelBuilder: buildWorkerOptionLabel,
      validator: validateRequiredTransactionSelection,
      searchMatcher: (worker, query) {
        final hrCode = worker.hrCode.trim().toLowerCase();
        final name = worker.name.trim().toLowerCase();
        final department = worker.department.trim().toLowerCase();

        return hrCode.contains(query) ||
            name.contains(query) ||
            department.contains(query);
      },
      onItemSelected: onSelected,
    );
  }
}
