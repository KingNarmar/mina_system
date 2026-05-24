import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/functions/show_lookup_message.dart';

Future<bool> addDepartmentLookup({
  required BuildContext context,
  required String department,
  required List<String> departments,
}) async {
  final cleanDepartment = department.trim();

  if (cleanDepartment.isEmpty) {
    showLookupMessage(
      context,
      'Please enter department name.',
      type: AppMessageType.warning,
    );
    return false;
  }

  final lookupsCubit = context.read<LookupsCubit>();
  final state = lookupsCubit.state;

  final alreadyActive = departments.any((item) {
    return _isSameLookupName(item, cleanDepartment);
  });

  if (alreadyActive) {
    showLookupMessage(
      context,
      'Department already exists.',
      type: AppMessageType.warning,
    );
    return false;
  }

  final alreadyInactive = state.inactiveDepartments.any((item) {
    return _isSameLookupName(item, cleanDepartment);
  });

  if (alreadyInactive) {
    showLookupMessage(
      context,
      'Department already exists but is inactive. Restore it instead.',
      type: AppMessageType.warning,
    );
    return false;
  }

  final companyId = context.requireCurrentCompanyId();

  final isAdded = await lookupsCubit.addDepartment(
    companyId: companyId,
    department: cleanDepartment,
  );

  if (!context.mounted) {
    return false;
  }

  if (isAdded) {
    showLookupMessage(
      context,
      'Department added successfully.',
      type: AppMessageType.success,
    );
  } else {
    final message =
        lookupsCubit.state.errorMessage ?? 'Department was not added.';
    lookupsCubit.clearErrorMessage();

    showLookupMessage(
      context,
      message,
      type: _departmentAddMessageType(message),
    );
  }

  return isAdded;
}

AppMessageType _departmentAddMessageType(String message) {
  final normalizedMessage = message.toLowerCase();

  if (normalizedMessage.contains('already exists') ||
      normalizedMessage.contains('restore it instead')) {
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
