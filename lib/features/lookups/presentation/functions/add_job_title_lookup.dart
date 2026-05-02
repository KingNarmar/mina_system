import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/functions/show_lookup_message.dart';

bool addJobTitleLookup({
  required BuildContext context,
  required String? department,
  required String jobTitle,
  required List<String> jobTitles,
}) {
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

  final isDuplicated = jobTitles.any((item) {
    return item.trim().toLowerCase() == cleanJobTitle.toLowerCase();
  });

  if (isDuplicated) {
    showLookupMessage(context, 'Job title already exists');
    return false;
  }

  context.read<LookupsCubit>().addJobTitle(
    department: cleanDepartment,
    jobTitle: cleanJobTitle,
  );

  showLookupMessage(context, 'Job title added successfully');

  return true;
}
