import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/presentation/widgets/table/workers_table_cell.dart';

class WorkersTableRow extends StatelessWidget {
  const WorkersTableRow({super.key, required this.worker, this.onEdit, this.onDelete});

  final WorkerModel worker;
  final void Function(WorkerModel worker)? onEdit;
  final void Function(WorkerModel worker)? onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              WorkersTableBodyCell(value: worker.name, flex: 3),
              WorkersTableBodyCell(value: worker.hrCode, flex: 2),
              WorkersTableBodyCell(value: worker.department, flex: 2),
              WorkersTableBodyCell(value: worker.jobTitle, flex: 2),
              WorkersTableBodyCell(value: worker.activeCustodyCount.toString(), flex: 2),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onEdit == null
                          ? null
                          : () {
                              onEdit!(worker);
                            },
                      icon: const Icon(Icons.edit_outlined),
                      color: AppColors.accent,
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: onDelete == null
                          ? null
                          : () {
                              onDelete!(worker);
                            },
                      icon: const Icon(Icons.delete_outline),
                      color: AppColors.error,
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}
