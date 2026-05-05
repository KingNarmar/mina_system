import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/functions/show_lookup_message.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';

Future<bool> deleteToolCategoryLookup({
  required BuildContext context,
  required String category,
}) async {
  final cleanCategory = category.trim();

  final isCategoryUsed = context.read<ToolsCubit>().state.tools.any((tool) {
    return _isSameLookupName(tool.category, cleanCategory);
  });

  if (isCategoryUsed) {
    showLookupMessage(
      context,
      'Cannot delete category because it is used by tools',
    );
    return false;
  }

  final isDeleted = await context.read<LookupsCubit>().deleteToolCategory(
    category: cleanCategory,
  );

  if (!context.mounted) {
    return false;
  }

  if (isDeleted) {
    showLookupMessage(context, 'Category deleted successfully');
  } else {
    showLookupMessage(context, 'Category was not deleted');
  }

  return isDeleted;
}

bool _isSameLookupName(String firstValue, String secondValue) {
  return _normalizeLookupName(firstValue) == _normalizeLookupName(secondValue);
}

String _normalizeLookupName(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
}
