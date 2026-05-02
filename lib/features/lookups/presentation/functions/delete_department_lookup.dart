import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/functions/show_lookup_message.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';

void deleteDepartmentLookup({
  required BuildContext context,
  required String department,
}) {
  final isDepartmentUsed = context.read<WorkersCubit>().state.workers.any((
    worker,
  ) {
    return worker.department.trim().toLowerCase() ==
        department.trim().toLowerCase();
  });

  if (isDepartmentUsed) {
    showLookupMessage(
      context,
      'Cannot delete department because it is used by workers',
    );
    return;
  }

  context.read<LookupsCubit>().deleteDepartment(department);

  showLookupMessage(context, 'Department deleted successfully');
}
