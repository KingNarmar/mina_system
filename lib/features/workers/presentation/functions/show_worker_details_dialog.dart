import 'package:flutter/material.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/presentation/widgets/dialogs/worker_details_dialog.dart';

void showWorkerDetailsDialog(
  BuildContext context, {
  required WorkerModel worker,
}) {
  final timezone = context.currentCompany?.timezone;

  showDialog(
    context: context,
    builder: (_) {
      return WorkerDetailsDialog(
        worker: worker,
        timezone: timezone,
      );
    },
  );
}