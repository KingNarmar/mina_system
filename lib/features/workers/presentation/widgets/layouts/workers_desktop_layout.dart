import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/widgets/app_empty_state.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';
import 'package:mina_system/features/workers/presentation/functions/confirm_delete_worker.dart';
import 'package:mina_system/features/workers/presentation/functions/show_worker_form.dart';
import 'package:mina_system/features/workers/presentation/widgets/worker_search_field.dart';
import 'package:mina_system/features/workers/presentation/widgets/workers_table.dart';

class WorkersDesktopLayout extends StatelessWidget {
  const WorkersDesktopLayout({
    super.key,
    required this.workers,
    required this.searchQuery,
    required this.canCreateWorkers,
    required this.canUpdateWorkers,
    required this.canDeleteWorkers,
  });

  final List<WorkerModel> workers;
  final String searchQuery;
  final bool canCreateWorkers;
  final bool canUpdateWorkers;
  final bool canDeleteWorkers;

  @override
  Widget build(BuildContext context) {
    final canShowActions = canUpdateWorkers || canDeleteWorkers;

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
          const Gap(16),
          if (workers.isEmpty)
            AppEmptyState(
              icon: Icons.people_outline,
              title: 'No workers found',
              message: canCreateWorkers
                  ? 'Add your first worker to start tracking tool custody.'
                  : 'No workers are currently available for your company.',
            )
          else
            SizedBox(
              width: double.infinity,
              child: WorkersTable(
                workers: workers,
                showActions: canShowActions,
                onEdit: canUpdateWorkers
                    ? (worker) {
                        showWorkerDialog(context, worker: worker);
                      }
                    : null,
                onDelete: canDeleteWorkers
                    ? (worker) {
                        confirmDeleteWorker(context, worker);
                      }
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}
