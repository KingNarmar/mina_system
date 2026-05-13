import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/presentation/widgets/table/workers_table_cell.dart';

class WorkersTableRow extends StatelessWidget {
  const WorkersTableRow({
    super.key,
    required this.worker,
    required this.showActions,
    this.onEdit,
    this.onDelete,
    this.onReactivate,
    this.onViewAuditHistory,
  });

  final WorkerModel worker;
  final bool showActions;
  final void Function(WorkerModel worker)? onEdit;
  final void Function(WorkerModel worker)? onDelete;
  final void Function(WorkerModel worker)? onReactivate;
  final void Function(WorkerModel worker)? onViewAuditHistory;

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
              if (showActions)
                Expanded(
                  flex: 2,
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      if (onViewAuditHistory != null)
                        IconButton(
                          onPressed: () {
                            onViewAuditHistory!(worker);
                          },
                          icon: const Icon(Icons.history_rounded),
                          color: AppColors.textSecondary,
                          tooltip: 'View Audit History',
                        ),
                      if (onEdit != null)
                        IconButton(
                          onPressed: () {
                            onEdit!(worker);
                          },
                          icon: const Icon(Icons.edit_outlined),
                          color: AppColors.accent,
                          tooltip: 'Edit',
                        ),
                      if (onDelete != null)
                        IconButton(
                          onPressed: () {
                            onDelete!(worker);
                          },
                          icon: const Icon(Icons.delete_outline),
                          color: AppColors.error,
                          tooltip: 'Deactivate',
                        ),
                      if (onReactivate != null)
                        IconButton(
                          onPressed: () {
                            onReactivate!(worker);
                          },
                          icon: const Icon(Icons.restore_outlined),
                          color: AppColors.accent,
                          tooltip: 'Reactivate',
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
