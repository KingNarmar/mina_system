import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    showLookupMessage(context, 'Please select department');
    return false;
  }

  if (cleanJobTitle.isEmpty) {
    showLookupMessage(context, 'Please enter job title');
    return false;
  }

  final companyId = context.requireCurrentCompanyId();

  final isAdded = await context.read<LookupsCubit>().addJobTitle(
    companyId: companyId,
    department: cleanDepartment,
    jobTitle: cleanJobTitle,
  );

  if (!context.mounted) {
    return false;
  }

  if (isAdded) {
    showLookupMessage(context, 'Job title added successfully');
  } else {
    showLookupMessage(context, 'Job title was not added');
  }

  return isAdded;
}
