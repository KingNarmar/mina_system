import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/functions/show_lookup_message.dart';

Future<bool> restoreJobTitleLookup({
  required BuildContext context,
  required String department,
  required String jobTitle,
}) async {
  final cleanDepartment = department.trim();
  final cleanJobTitle = jobTitle.trim();

  if (cleanDepartment.isEmpty) {
    showLookupMessage(
      context,
      'Department was not found.',
      type: AppMessageType.warning,
    );
    return false;
  }

  if (cleanJobTitle.isEmpty) {
    showLookupMessage(
      context,
      'Job title was not found.',
      type: AppMessageType.warning,
    );
    return false;
  }

  final lookupsCubit = context.read<LookupsCubit>();

  final departmentModel = lookupsCubit.state.departmentModels
      .where((item) => _isSameLookupName(item.name, cleanDepartment))
      .firstOrNull;

  if (departmentModel == null) {
    showLookupMessage(
      context,
      'Restore the department before restoring its job titles.',
      type: AppMessageType.warning,
    );
    return false;
  }

  final inactiveJobTitleModel = lookupsCubit.state.inactiveJobTitleModels.where(
    (item) {
      final isSameDepartment = item.departmentId == departmentModel.id;
      final isSameJobTitle = _isSameLookupName(item.name, cleanJobTitle);

      return isSameDepartment && isSameJobTitle;
    },
  ).firstOrNull;

  if (inactiveJobTitleModel == null) {
    showLookupMessage(
      context,
      'Inactive job title was not found.',
      type: AppMessageType.warning,
    );
    return false;
  }

  final isRestored = await lookupsCubit.reactivateJobTitle(
    department: cleanDepartment,
    jobTitle: cleanJobTitle,
  );

  if (!context.mounted) {
    return false;
  }

  if (isRestored) {
    showLookupMessage(
      context,
      'Job title restored successfully.',
      type: AppMessageType.success,
    );
  } else {
    final message =
        lookupsCubit.state.errorMessage ?? 'Job title was not restored.';
    lookupsCubit.clearErrorMessage();

    showLookupMessage(
      context,
      message,
      type: _jobTitleRestoreMessageType(message),
    );
  }

  return isRestored;
}

AppMessageType _jobTitleRestoreMessageType(String message) {
  final normalizedMessage = message.toLowerCase();

  if (normalizedMessage.contains('not found') ||
      normalizedMessage.contains('restore the department')) {
    return AppMessageType.warning;
  }

  return AppMessageType.error;
}

bool _isSameLookupName(String firstValue, String secondValue) {
  return _normalizeLookupName(firstValue) == _normalizeLookupName(secondValue);
}

String _normalizeLookupName(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
}
