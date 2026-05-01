import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';
import 'package:mina_system/features/workers/presentation/widgets/add_worker_form.dart';
import 'package:mina_system/features/workers/presentation/functions/show_worker_message.dart';

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
            _saveWorker(context, worker, savedWorker);
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
              isHrCodeAlreadyUsed: context.read<WorkersCubit>().isHrCodeAlreadyUsed,
              onSave: (savedWorker) {
                _saveWorker(context, worker, savedWorker);
              },
            ),
          ),
        ),
      );
    },
  );
}

void _saveWorker(BuildContext context, WorkerModel? originalWorker, WorkerModel savedWorker) {
  if (originalWorker == null) {
    context.read<WorkersCubit>().addWorker(savedWorker);
    showWorkerSuccessMessage(context, 'Worker added successfully');
    return;
  }

  context.read<WorkersCubit>().updateWorker(
    currentHrCode: originalWorker.hrCode,
    updatedWorker: savedWorker,
  );

  showWorkerSuccessMessage(context, 'Worker updated successfully');
}
