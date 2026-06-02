import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/widgets/app_empty_state.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';
import 'package:mina_system/features/workers/presentation/functions/confirm_delete_worker.dart';
import 'package:mina_system/features/workers/presentation/functions/confirm_reactivate_worker.dart';
import 'package:mina_system/features/workers/presentation/functions/show_worker_audit_history.dart';
import 'package:mina_system/features/workers/presentation/functions/show_worker_form.dart';
import 'package:mina_system/features/workers/presentation/widgets/card/worker_card.dart';
import 'package:mina_system/features/workers/presentation/widgets/worker_search_field.dart';
import 'package:mina_system/core/theme/app_icons.dart';

class WorkersMobileLayout extends StatelessWidget {
  const WorkersMobileLayout({
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
    final timezone = context.currentCompany?.timezone;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        itemCount: workers.isEmpty ? 3 : workers.length + 2,
        separatorBuilder: (context, index) {
          return const Gap(12);
        },
        itemBuilder: (context, index) {
          if (index == 0) {
            return WorkerSearchField(
              initialQuery: searchQuery,
              onChanged: (value) {
                context.read<WorkersCubit>().searchWorkers(value);
              },
            );
          }

          if (index == 1) {
            return _WorkerStatusFilter(
              selectedStatus: statusFilter,
              onChanged: onStatusFilterChanged,
            );
          }

          if (workers.isEmpty) {
            return AppEmptyState(
              icon: AppIcons.workers,
              title: isActiveFilter
                  ? 'No active workers found'
                  : 'No inactive workers found',
              message: isActiveFilter
                  ? canCreateWorkers
                        ? 'Add your first worker to start tracking tool custody.'
                        : 'No active workers are currently available for your company.'
                  : 'Deactivated workers will appear here.',
            );
          }

          final worker = workers[index - 2];

          return WorkerCard(
            worker: worker,
            timezone: timezone,
            onViewAuditHistory: () {
              showWorkerAuditHistory(context, worker: worker);
            },
            onEdit: canUpdateWorkers
                ? () {
                    showWorkerBottomSheet(context, worker: worker);
                  }
                : null,
            onDelete: canDeleteWorkers && isActiveFilter
                ? () {
                    confirmDeleteWorker(context, worker);
                  }
                : null,
            onReactivate: canDeleteWorkers && !isActiveFilter
                ? () {
                    confirmReactivateWorker(context, worker);
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
              child: const Icon(AppIcons.add),
            )
          : null,
    );
  }
}

class _WorkerStatusFilter extends StatelessWidget {
  const _WorkerStatusFilter({
    required this.selectedStatus,
    required this.onChanged,
  });

  final String selectedStatus;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text('Active'),
          selected: selectedStatus == 'active',
          onSelected: (_) {
            onChanged('active');
          },
        ),
        ChoiceChip(
          label: const Text('Inactive'),
          selected: selectedStatus == 'inactive',
          onSelected: (_) {
            onChanged('inactive');
          },
        ),
      ],
    );
  }
}
