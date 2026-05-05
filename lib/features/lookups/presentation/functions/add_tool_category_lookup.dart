import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/functions/show_lookup_message.dart';

Future<bool> addToolCategoryLookup({
  required BuildContext context,
  required String category,
  required List<String> categories,
}) async {
  final cleanCategory = category.trim();

  if (cleanCategory.isEmpty) {
    showLookupMessage(context, 'Please enter category');
    return false;
  }

  final companyId = context.requireCurrentCompanyId();

  final isAdded = await context.read<LookupsCubit>().addToolCategory(
    companyId: companyId,
    category: cleanCategory,
  );

  if (!context.mounted) {
    return false;
  }

  if (isAdded) {
    showLookupMessage(context, 'Category added successfully');
  } else {
    showLookupMessage(context, 'Category was not added');
  }

  return isAdded;
}
