import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/functions/show_lookup_message.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';

Future<bool> deleteDepartmentLookup({
  required BuildContext context,
  required String department,
}) async {
  final cleanDepartment = department.trim();

  final lookupsCubit = context.read<LookupsCubit>();

  final departmentModel = lookupsCubit.state.departmentModels
      .where((item) => _isSameLookupName(item.name, cleanDepartment))
      .firstOrNull;

  if (departmentModel == null) {
    showLookupMessage(context, 'Department was not found');
    return false;
  }

  final hasJobTitles = lookupsCubit.state.jobTitleModels.any((jobTitle) {
    return jobTitle.departmentId == departmentModel.id;
  });

  if (hasJobTitles) {
    showLookupMessage(
      context,
      'Cannot delete department because it has job titles',
    );
    return false;
  }

  final isDepartmentUsed = context.read<WorkersCubit>().state.workers.any((
    worker,
  ) {
    return _isSameLookupName(worker.department, cleanDepartment);
  });

  if (isDepartmentUsed) {
    showLookupMessage(
      context,
      'Cannot delete department because it is used by workers',
    );
    return false;
  }

  final isDeleted = await lookupsCubit.deleteDepartment(
    departmentId: departmentModel.id,
  );

  if (!context.mounted) {
    return false;
  }

  if (isDeleted) {
    showLookupMessage(context, 'Department deleted successfully');
  } else {
    showLookupMessage(context, 'Department was not deleted');
  }

  return isDeleted;
}

bool _isSameLookupName(String firstValue, String secondValue) {
  return _normalizeLookupName(firstValue) == _normalizeLookupName(secondValue);
}

String _normalizeLookupName(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
}
