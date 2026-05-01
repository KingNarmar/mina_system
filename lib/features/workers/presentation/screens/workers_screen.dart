import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_state.dart';
import 'package:mina_system/features/workers/presentation/widgets/add_worker_form.dart';
import 'package:mina_system/features/workers/presentation/widgets/worker_card.dart';
import 'package:mina_system/features/workers/presentation/widgets/worker_search_field.dart';
import 'package:mina_system/features/workers/presentation/widgets/workers_table.dart';

class WorkersScreen extends StatelessWidget {
  const WorkersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WorkersView();
  }
}

class _WorkersView extends StatelessWidget {
  const _WorkersView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkersCubit, WorkersState>(
      builder: (context, state) {
        final workers = state.filteredWorkers;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < AppBreakpoints.tablet;

            if (isMobile) {
              return _WorkersMobileLayout(workers: workers);
            }

            return _WorkersDesktopLayout(workers: workers);
          },
        );
      },
    );
  }
}

class _WorkersMobileLayout extends StatelessWidget {
  const _WorkersMobileLayout({required this.workers});

  final List<WorkerModel> workers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        itemCount: workers.length + 1,
        separatorBuilder: (context, index) {
          return const SizedBox(height: 12);
        },
        itemBuilder: (context, index) {
          if (index == 0) {
            return WorkerSearchField(
              onChanged: (value) {
                context.read<WorkersCubit>().searchWorkers(value);
              },
            );
          }

          final worker = workers[index - 1];

          return WorkerCard(
            worker: worker,
            onDelete: () {
              _confirmDeleteWorker(context, worker);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddWorkerBottomSheet(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _WorkersDesktopLayout extends StatelessWidget {
  const _WorkersDesktopLayout({required this.workers});

  final List<WorkerModel> workers;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: WorkerSearchField(
                  onChanged: (value) {
                    context.read<WorkersCubit>().searchWorkers(value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showAddWorkerDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Worker'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: WorkersTable(
              workers: workers,
              onDelete: (worker) {
                _confirmDeleteWorker(context, worker);
              },
            ),
          ),
        ],
      ),
    );
  }
}

void _showAddWorkerBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return AddWorkerForm(
        onSave: (worker) {
          context.read<WorkersCubit>().addWorker(worker);
        },
      );
    },
  );
}

void _showAddWorkerDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: 460,
          child: AddWorkerForm(
            onSave: (worker) {
              context.read<WorkersCubit>().addWorker(worker);
            },
          ),
        ),
      );
    },
  );
}

void _confirmDeleteWorker(BuildContext context, WorkerModel worker) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Delete Worker'),
        content: Text('Are you sure you want to delete ${worker.name}?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<WorkersCubit>().deleteWorker(worker);
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
