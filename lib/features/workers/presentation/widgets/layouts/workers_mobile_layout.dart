import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/widgets/app_empty_state.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';
import 'package:mina_system/features/workers/presentation/functions/confirm_delete_worker.dart';
import 'package:mina_system/features/workers/presentation/functions/show_worker_form.dart';
import 'package:mina_system/features/workers/presentation/widgets/card/worker_card.dart';
import 'package:mina_system/features/workers/presentation/widgets/worker_search_field.dart';

class WorkersMobileLayout extends StatelessWidget {
  const WorkersMobileLayout({
    super.key,
    required this.workers,
    required this.canCreateWorkers,
    required this.canUpdateWorkers,
    required this.canDeleteWorkers,
  });

  final List<WorkerModel> workers;
  final bool canCreateWorkers;
  final bool canUpdateWorkers;
  final bool canDeleteWorkers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        itemCount: workers.isEmpty ? 2 : workers.length + 1,
        separatorBuilder: (context, index) {
          return const Gap(12);
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
            return AppEmptyState(
              icon: Icons.people_outline,
              title: 'No workers found',
              message: canCreateWorkers
                  ? 'Add your first worker to start tracking tool custody.'
                  : 'No workers are currently available for your company.',
            );
          }

          final worker = workers[index - 1];

          return WorkerCard(
            worker: worker,
            onEdit: canUpdateWorkers
                ? () {
                    showWorkerBottomSheet(context, worker: worker);
                  }
                : null,
            onDelete: canDeleteWorkers
                ? () {
                    confirmDeleteWorker(context, worker);
                  }
                : null,
          );
        },
      ),
      floatingActionButton: canCreateWorkers
          ? FloatingActionButton(
              onPressed: () {
                showWorkerBottomSheet(context);
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
