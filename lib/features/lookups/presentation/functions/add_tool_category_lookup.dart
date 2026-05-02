import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/functions/show_lookup_message.dart';

bool addToolCategoryLookup({
  required BuildContext context,
  required String category,
  required List<String> categories,
}) {
  final cleanCategory = category.trim();

  if (cleanCategory.isEmpty) {
    showLookupMessage(context, 'Please enter category');
    return false;
  }

  final isDuplicated = categories.any((item) {
    return item.trim().toLowerCase() == cleanCategory.toLowerCase();
  });

  if (isDuplicated) {
    showLookupMessage(context, 'Category already exists');
    return false;
  }

  context.read<LookupsCubit>().addToolCategory(cleanCategory);

  showLookupMessage(context, 'Category added successfully');

  return true;
}