import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/widgets/app_empty_state.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';
import 'package:mina_system/features/workers/presentation/functions/confirm_delete_worker.dart';
import 'package:mina_system/features/workers/presentation/functions/show_worker_form.dart';
import 'package:mina_system/features/workers/presentation/widgets/card/worker_card.dart';
import 'package:mina_system/features/workers/presentation/widgets/worker_search_field.dart';

class WorkersMobileLayout extends StatelessWidget {
  const WorkersMobileLayout({super.key, required this.workers});

  final List<WorkerModel> workers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        itemCount: workers.isEmpty ? 2 : workers.length + 1,
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

          if (workers.isEmpty) {
            return const AppEmptyState(
              icon: Icons.people_outline,
              title: 'No workers found',
              message: 'Add your first worker to start tracking tool custody.',
            );
          }

          final worker = workers[index - 1];

          return WorkerCard(
            worker: worker,
            onEdit: () {
              showWorkerBottomSheet(context, worker: worker);
            },
            onDelete: () {
              confirmDeleteWorker(context, worker);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showWorkerBottomSheet(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
