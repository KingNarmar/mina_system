import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';

class WorkersTable extends StatelessWidget {
  const WorkersTable({super.key, required this.workers, this.onDelete});

  final List<WorkerModel> workers;
  final void Function(WorkerModel worker)? onDelete;
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
          const _WorkersTableHeader(),
          const Divider(height: 1, color: AppColors.border),
          if (workers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No workers found', style: AppTextStyles.body),
            )
          else
            ...workers.map((worker) {
              return _WorkersTableRow(worker: worker, onDelete: onDelete);
            }),
        ],
      ),
    );
  }
}

class _WorkersTableHeader extends StatelessWidget {
  const _WorkersTableHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          _HeaderCell(title: 'Worker Name', flex: 3),
          _HeaderCell(title: 'HR Code', flex: 2),
          _HeaderCell(title: 'Department', flex: 2),
          _HeaderCell(title: 'Job Title', flex: 2),
          _HeaderCell(title: 'Active Custody', flex: 2),
          _HeaderCell(title: 'Actions', flex: 1),
        ],
      ),
    );
  }
}

class _WorkersTableRow extends StatelessWidget {
  const _WorkersTableRow({required this.worker, this.onDelete});

  final WorkerModel worker;
  final void Function(WorkerModel worker)? onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              _BodyCell(value: worker.name, flex: 3),
              _BodyCell(value: worker.hrCode, flex: 2),
              _BodyCell(value: worker.department, flex: 2),
              _BodyCell(value: worker.jobTitle, flex: 2),
              _BodyCell(value: worker.activeCustodyCount.toString(), flex: 2),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: onDelete == null
                        ? null
                        : () {
                            onDelete!(worker);
                          },
                    icon: const Icon(Icons.delete_outline),
                    color: AppColors.error,
                    tooltip: 'Delete',
                  ),
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

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.title, required this.flex});

  final String title;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell({required this.value, required this.flex});

  final String value;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        value,
        style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
