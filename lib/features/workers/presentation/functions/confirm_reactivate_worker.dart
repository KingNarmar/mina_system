import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';
import 'package:mina_system/features/workers/presentation/functions/show_worker_message.dart';

void confirmReactivateWorker(BuildContext context, WorkerModel worker) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Reactivate Worker'),
        content: Text(
          'Are you sure you want to reactivate ${worker.name}? '
          'The worker will appear again in active lists.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              final isReactivated = await context
                  .read<WorkersCubit>()
                  .reactivateWorker(worker: worker);

              if (!context.mounted) {
                return;
              }

              showWorkerSuccessMessage(
                context,
                isReactivated
                    ? 'Worker reactivated successfully'
                    : 'Worker was not reactivated',
              );
            },
            child: const Text('Reactivate'),
          ),
        ],
      );
    },
  );
}
