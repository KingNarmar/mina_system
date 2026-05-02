import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/functions/show_lookup_message.dart';

bool addDepartmentLookup({
  required BuildContext context,
  required String department,
  required List<String> departments,
}) {
  final cleanDepartment = department.trim();

  if (cleanDepartment.isEmpty) {
    showLookupMessage(context, 'Please enter department name');
    return false;
  }

  final isDuplicated = departments.any((item) {
    return item.trim().toLowerCase() == cleanDepartment.toLowerCase();
  });

  if (isDuplicated) {
    showLookupMessage(context, 'Department already exists');
    return false;
  }

  context.read<LookupsCubit>().addDepartment(cleanDepartment);

  showLookupMessage(context, 'Department added successfully');

  return true;
}
