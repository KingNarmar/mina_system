import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/functions/show_lookup_message.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';

void deleteJobTitleLookup({
  required BuildContext context,
  required String department,
  required String jobTitle,
}) {
  final isJobTitleUsed = context.read<WorkersCubit>().state.workers.any((
    worker,
  ) {
    final isSameDepartment =
        worker.department.trim().toLowerCase() ==
        department.trim().toLowerCase();

    final isSameJobTitle =
        worker.jobTitle.trim().toLowerCase() == jobTitle.trim().toLowerCase();

    return isSameDepartment && isSameJobTitle;
  });

  if (isJobTitleUsed) {
    showLookupMessage(
      context,
      'Cannot delete job title because it is used by workers',
    );
    return;
  }

  context.read<LookupsCubit>().deleteJobTitle(
    department: department,
    jobTitle: jobTitle,
  );

  showLookupMessage(context, 'Job title deleted successfully');
}
