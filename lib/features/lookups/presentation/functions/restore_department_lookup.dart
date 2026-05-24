import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/functions/show_lookup_message.dart';

Future<bool> restoreDepartmentLookup({
  required BuildContext context,
  required String department,
}) async {
  final cleanDepartment = department.trim();

  if (cleanDepartment.isEmpty) {
    showLookupMessage(
      context,
      'Department was not found.',
      type: AppMessageType.warning,
    );
    return false;
  }

  final isRestored = await context.read<LookupsCubit>().reactivateDepartment(
    department: cleanDepartment,
  );

  if (!context.mounted) {
    return false;
  }

  if (isRestored) {
    showLookupMessage(
      context,
      'Department restored successfully.',
      type: AppMessageType.success,
    );
  }

  return isRestored;
}
