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
      'Cannot delete job title because it is used by workers',
      type: AppMessageType.warning,
    );
    return false;
  }

  final lookupsCubit = context.read<LookupsCubit>();

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
      'Job title deleted successfully',
      type: AppMessageType.success,
    );
  } else {
    final message =
        lookupsCubit.state.errorMessage ?? 'Job title was not deleted';
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
