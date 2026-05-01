import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';
import 'package:mina_system/features/workers/presentation/widgets/worker_search_field.dart';
import 'package:mina_system/features/workers/presentation/widgets/workers_table.dart';
import 'package:mina_system/features/workers/presentation/functions/show_worker_form.dart';
import 'package:mina_system/features/workers/presentation/functions/confirm_delete_worker.dart';

class WorkersDesktopLayout extends StatelessWidget {
  const WorkersDesktopLayout({super.key, required this.workers});

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
                    showWorkerDialog(context);
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
              onEdit: (worker) {
                showWorkerDialog(context, worker: worker);
              },
              onDelete: (worker) {
                confirmDeleteWorker(context, worker);
              },
            ),
          ),
        ],
      ),
    );
  }
}
