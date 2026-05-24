import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/functions/show_lookup_message.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';

Future<bool> deleteJobTitleLookup({
  required BuildContext context,
  required String department,
  required String jobTitle,
}) async {
  final cleanDepartment = department.trim();
  final cleanJobTitle = jobTitle.trim();

  final lookupsCubit = context.read<LookupsCubit>();

  final departmentModel = lookupsCubit.state.departmentModels
      .where((item) => _isSameLookupName(item.name, cleanDepartment))
      .firstOrNull;

  if (departmentModel == null) {
    showLookupMessage(
      context,
      'Department was not found.',
      type: AppMessageType.warning,
    );
    return false;
  }

  final jobTitleModel = lookupsCubit.state.jobTitleModels.where((item) {
    final isSameDepartment = item.departmentId == departmentModel.id;
    final isSameJobTitle = _isSameLookupName(item.name, cleanJobTitle);

    return isSameDepartment && isSameJobTitle;
  }).firstOrNull;

  if (jobTitleModel == null) {
    showLookupMessage(
      context,
      'Job title was not found.',
      type: AppMessageType.warning,
    );
    return false;
  }

  final isJobTitleUsed = context.read<WorkersCubit>().state.workers.any((
    worker,
  ) {
    final isSameDepartment = _isSameLookupName(
      worker.department,
      cleanDepartment,
    );

    final isSameJobTitle = _isSameLookupName(worker.jobTitle, cleanJobTitle);

    return isSameDepartment && isSameJobTitle;
  });

  if (isJobTitleUsed) {
    showLookupMessage(
      context,
      'This job title is used by workers and cannot be deactivated.',
      type: AppMessageType.warning,
    );
    return false;
  }

  final isDeleted = await lookupsCubit.deleteJobTitle(
    department: cleanDepartment,
    jobTitle: cleanJobTitle,
  );

  if (!context.mounted) {
    return false;
  }

  if (isDeleted) {
    showLookupMessage(
      context,
      'Job title deactivated successfully.',
      type: AppMessageType.success,
    );
  } else {
    final message =
        lookupsCubit.state.errorMessage ?? 'Job title was not deactivated.';
    lookupsCubit.clearErrorMessage();

    showLookupMessage(context, message, type: AppMessageType.error);
  }

  return isDeleted;
}

bool _isSameLookupName(String firstValue, String secondValue) {
  return _normalizeLookupName(firstValue) == _normalizeLookupName(secondValue);
}

String _normalizeLookupName(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
}
