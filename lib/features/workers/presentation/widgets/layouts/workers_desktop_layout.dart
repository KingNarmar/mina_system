import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/widgets/app_empty_state.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';
import 'package:mina_system/features/workers/presentation/functions/confirm_delete_worker.dart';
import 'package:mina_system/features/workers/presentation/functions/confirm_reactivate_worker.dart';
import 'package:mina_system/features/workers/presentation/functions/show_worker_audit_history.dart';
import 'package:mina_system/features/workers/presentation/functions/show_worker_form.dart';
import 'package:mina_system/features/workers/presentation/widgets/worker_search_field.dart';
import 'package:mina_system/features/workers/presentation/widgets/workers_table.dart';

class WorkersDesktopLayout extends StatelessWidget {
  const WorkersDesktopLayout({
    super.key,
    required this.workers,
    required this.searchQuery,
    required this.statusFilter,
    required this.onStatusFilterChanged,
    required this.canCreateWorkers,
    required this.canUpdateWorkers,
    required this.canDeleteWorkers,
  });

  final List<WorkerModel> workers;
  final String searchQuery;
  final String statusFilter;
  final ValueChanged<String> onStatusFilterChanged;
  final bool canCreateWorkers;
  final bool canUpdateWorkers;
  final bool canDeleteWorkers;

  @override
  Widget build(BuildContext context) {
    final isActiveFilter = statusFilter == 'active';
    final canShowActions = true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: WorkerSearchField(
                  initialQuery: searchQuery,
                  onChanged: (value) {
                    context.read<WorkersCubit>().searchWorkers(value);
                  },
                ),
              ),
              if (canCreateWorkers) ...[
                const Gap(16),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showWorkerDialog(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Worker'),
                  ),
                ),
              ],
            ],
          ),
          const Gap(12),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Active'),
                  selected: statusFilter == 'active',
                  onSelected: (_) {
                    onStatusFilterChanged('active');
                  },
                ),
                ChoiceChip(
                  label: const Text('Inactive'),
                  selected: statusFilter == 'inactive',
                  onSelected: (_) {
                    onStatusFilterChanged('inactive');
                  },
                ),
              ],
            ),
          ),
          const Gap(16),
          if (workers.isEmpty)
            AppEmptyState(
              icon: Icons.people_outline,
              title: isActiveFilter
                  ? 'No active workers found'
                  : 'No inactive workers found',
              message: isActiveFilter
                  ? canCreateWorkers
                        ? 'Add your first worker to start tracking tool custody.'
                        : 'No active workers are currently available for your company.'
                  : 'Deactivated workers will appear here.',
            )
          else
            SizedBox(
              width: double.infinity,
              child: WorkersTable(
                workers: workers,
                showActions: canShowActions,
                onViewAuditHistory: (worker) {
                  showWorkerAuditHistory(context, worker: worker);
                },
                onEdit: canUpdateWorkers
                    ? (worker) {
                        showWorkerDialog(context, worker: worker);
                      }
                    : null,
                onDelete: canDeleteWorkers && isActiveFilter
                    ? (worker) {
                        confirmDeleteWorker(context, worker);
                      }
                    : null,
                onReactivate: canDeleteWorkers && !isActiveFilter
                    ? (worker) {
                        confirmReactivateWorker(context, worker);
                      }
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}
