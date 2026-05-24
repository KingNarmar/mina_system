import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/functions/show_lookup_message.dart';

Future<bool> addJobTitleLookup({
  required BuildContext context,
  required String? department,
  required String jobTitle,
  required List<String> jobTitles,
}) async {
  final cleanDepartment = department?.trim() ?? '';
  final cleanJobTitle = jobTitle.trim();

  if (cleanDepartment.isEmpty) {
    showLookupMessage(
      context,
      'Please select department.',
      type: AppMessageType.warning,
    );
    return false;
  }

  if (cleanJobTitle.isEmpty) {
    showLookupMessage(
      context,
      'Please enter job title.',
      type: AppMessageType.warning,
    );
    return false;
  }

  final lookupsCubit = context.read<LookupsCubit>();
  final state = lookupsCubit.state;

  final departmentModel = state.departmentModels
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

  final alreadyActive = state.jobTitleModels.any((item) {
    final isSameDepartment = item.departmentId == departmentModel.id;
    final isSameJobTitle = _isSameLookupName(item.name, cleanJobTitle);

    return isSameDepartment && isSameJobTitle;
  });

  if (alreadyActive) {
    showLookupMessage(
      context,
      'Job title already exists.',
      type: AppMessageType.warning,
    );
    return false;
  }

  final alreadyInactive = state.inactiveJobTitleModels.any((item) {
    final isSameDepartment = item.departmentId == departmentModel.id;
    final isSameJobTitle = _isSameLookupName(item.name, cleanJobTitle);

    return isSameDepartment && isSameJobTitle;
  });

  if (alreadyInactive) {
    showLookupMessage(
      context,
      'Job title already exists but is inactive. Restore it instead.',
      type: AppMessageType.warning,
    );
    return false;
  }

  final companyId = context.requireCurrentCompanyId();

  final isAdded = await lookupsCubit.addJobTitle(
    companyId: companyId,
    department: cleanDepartment,
    jobTitle: cleanJobTitle,
  );

  if (!context.mounted) {
    return false;
  }

  if (isAdded) {
    showLookupMessage(
      context,
      'Job title added successfully.',
      type: AppMessageType.success,
    );
  } else {
    final message =
        lookupsCubit.state.errorMessage ?? 'Job title was not added.';
    lookupsCubit.clearErrorMessage();

    showLookupMessage(context, message, type: _jobTitleAddMessageType(message));
  }

  return isAdded;
}

AppMessageType _jobTitleAddMessageType(String message) {
  final normalizedMessage = message.toLowerCase();

  if (normalizedMessage.contains('already exists') ||
      normalizedMessage.contains('restore it instead') ||
      normalizedMessage.contains('not found')) {
    return AppMessageType.warning;
  }

  return AppMessageType.error;
}

bool _isSameLookupName(String firstValue, String secondValue) {
  return _normalizeLookupName(firstValue) == _normalizeLookupName(secondValue);
}

String _normalizeLookupName(String value) {
  return value.trim().toLowerCase().replaceAll(
    RegExp(r'[^\p{L}\p{N}]+', unicode: true),
    '',
  );
}
