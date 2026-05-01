import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';
import 'package:mina_system/features/workers/presentation/functions/show_worker_message.dart';

void confirmDeleteWorker(BuildContext context, WorkerModel worker) {
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
              showWorkerSuccessMessage(context, 'Worker deleted successfully');
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
