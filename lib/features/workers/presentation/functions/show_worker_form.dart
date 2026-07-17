import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';
import 'package:mina_system/features/workers/presentation/widgets/add_worker_form.dart';

void showWorkerBottomSheet(BuildContext context, {WorkerModel? worker}) {
  final workersCubit = context.read<WorkersCubit>();
  final lookupsCubit = context.read<LookupsCubit>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return SafeArea(
        top: false,
        child: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: workersCubit),
            BlocProvider.value(value: lookupsCubit),
          ],
          child: AddWorkerForm(
            initialWorker: worker,
            isHrCodeAlreadyUsed: workersCubit.isHrCodeAlreadyUsed,
            isWorkerNameAlreadyUsed: workersCubit.isWorkerNameAlreadyUsed,
            onSave: (savedWorker) {
              return _saveWorker(
                context: context,
                originalWorker: worker,
                savedWorker: savedWorker,
              );
            },
          ),
        ),
      );
    },
  );
}

void showWorkerDialog(BuildContext context, {WorkerModel? worker}) {
  final workersCubit = context.read<WorkersCubit>();
  final lookupsCubit = context.read<LookupsCubit>();

  showDialog(
    context: context,
    builder: (_) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: 460,
          child: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: workersCubit),
              BlocProvider.value(value: lookupsCubit),
            ],
            child: AddWorkerForm(
              initialWorker: worker,
              isHrCodeAlreadyUsed: workersCubit.isHrCodeAlreadyUsed,
              isWorkerNameAlreadyUsed: workersCubit.isWorkerNameAlreadyUsed,
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

Future<String?> _saveWorker({
  required BuildContext context,
  required WorkerModel? originalWorker,
  required WorkerModel savedWorker,
}) async {
  final companyId = context.currentCompanyId;
  final workersCubit = context.read<WorkersCubit>();
  final dashboardCubit = context.read<DashboardCubit>();

  if (companyId == null || companyId.isEmpty) {
    return 'Company ID was not found';
  }

  if (originalWorker == null) {
    final isAdded = await workersCubit.addWorker(
      companyId: companyId,
      worker: savedWorker,
    );

    if (!context.mounted) {
      return 'Unable to save worker.';
    }

    if (!isAdded) {
      final errorMessage =
          workersCubit.state.errorMessage ?? 'Worker was not added.';
      workersCubit.clearErrorMessage();
      return errorMessage;
    }

    await dashboardCubit.loadDashboardSummary(companyId: companyId);

    if (context.mounted) {
      AppMessage.showSuccess(context, 'Worker added successfully');
    }

    return null;
  }

  final isUpdated = await workersCubit.updateWorker(
    companyId: companyId,
    updatedWorker: savedWorker,
  );

  if (!context.mounted) {
    return 'Unable to save worker.';
  }

  if (!isUpdated) {
    final errorMessage =
        workersCubit.state.errorMessage ?? 'Worker was not updated.';
    workersCubit.clearErrorMessage();
    return errorMessage;
  }

  await dashboardCubit.loadDashboardSummary(companyId: companyId);

  if (context.mounted) {
    AppMessage.showSuccess(context, 'Worker updated successfully');
  }

  return null;
}
