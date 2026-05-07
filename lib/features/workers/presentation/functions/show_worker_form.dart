import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';
import 'package:mina_system/features/workers/presentation/functions/show_worker_message.dart';
import 'package:mina_system/features/workers/presentation/widgets/add_worker_form.dart';

void showWorkerBottomSheet(BuildContext context, {WorkerModel? worker}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return BlocProvider.value(
        value: context.read<LookupsCubit>(),
        child: AddWorkerForm(
          initialWorker: worker,
          isHrCodeAlreadyUsed: context.read<WorkersCubit>().isHrCodeAlreadyUsed,
          onSave: (savedWorker) {
            return _saveWorker(
              context: context,
              originalWorker: worker,
              savedWorker: savedWorker,
            );
          },
        ),
      );
    },
  );
}

void showWorkerDialog(BuildContext context, {WorkerModel? worker}) {
  showDialog(
    context: context,
    builder: (_) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: 460,
          child: BlocProvider.value(
            value: context.read<LookupsCubit>(),
            child: AddWorkerForm(
              initialWorker: worker,
              isHrCodeAlreadyUsed: context
                  .read<WorkersCubit>()
                  .isHrCodeAlreadyUsed,
              onSave: (savedWorker) {
                return _saveWorker(
                  context: context,
                  originalWorker: worker,
                  savedWorker: savedWorker,
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

Future<bool> _saveWorker({
  required BuildContext context,
  required WorkerModel? originalWorker,
  required WorkerModel savedWorker,
}) async {
  final companyId = context.requireCurrentCompanyId();
  final dashboardCubit = context.read<DashboardCubit>();

  if (originalWorker == null) {
    final profileId = context.requireCurrentProfileId();

    final isAdded = await context.read<WorkersCubit>().addWorker(
      companyId: companyId,
      createdByProfileId: profileId,
      worker: savedWorker,
    );

    if (!context.mounted) {
      return false;
    }

    if (isAdded) {
      await dashboardCubit.loadDashboardSummary(companyId: companyId);
    }

    if (!context.mounted) {
      return false;
    }

    showWorkerSuccessMessage(
      context,
      isAdded ? 'Worker added successfully' : 'Worker was not added',
    );

    return isAdded;
  }

  final isUpdated = await context.read<WorkersCubit>().updateWorker(
    companyId: companyId,
    updatedWorker: savedWorker,
  );

  if (!context.mounted) {
    return false;
  }

  if (isUpdated) {
    await dashboardCubit.loadDashboardSummary(companyId: companyId);
  }

  if (!context.mounted) {
    return false;
  }

  showWorkerSuccessMessage(
    context,
    isUpdated ? 'Worker updated successfully' : 'Worker was not updated',
  );

  return isUpdated;
}
