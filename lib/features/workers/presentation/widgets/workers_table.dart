import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/presentation/widgets/table/workers_table_header.dart';
import 'package:mina_system/features/workers/presentation/widgets/table/workers_table_row.dart';

class WorkersTable extends StatelessWidget {
  const WorkersTable({
    super.key,
    required this.workers,
    required this.showActions,
    this.onViewDetails,
    this.onEdit,
    this.onDelete,
    this.onReactivate,
    this.onViewAuditHistory,
  });

  final List<WorkerModel> workers;
  final bool showActions;
  final void Function(WorkerModel worker)? onViewDetails;
  final void Function(WorkerModel worker)? onEdit;
  final void Function(WorkerModel worker)? onDelete;
  final void Function(WorkerModel worker)? onReactivate;
  final void Function(WorkerModel worker)? onViewAuditHistory;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        children: [
          WorkersTableHeader(showActions: showActions),
          const Divider(height: 1, color: AppColors.border),
          if (workers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No workers found', style: AppTextStyles.body),
            )
          else
            ...workers.map((worker) {
              return WorkersTableRow(
                worker: worker,
                showActions: showActions,
                onViewDetails: onViewDetails,
                onEdit: onEdit,
                onDelete: onDelete,
                onReactivate: onReactivate,
                onViewAuditHistory: onViewAuditHistory,
              );
            }),
        ],
      ),
    );
  }
}
