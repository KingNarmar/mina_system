import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/functions/show_lookup_message.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';

void deleteToolCategoryLookup({
  required BuildContext context,
  required String category,
}) {
  final isCategoryUsed = context.read<ToolsCubit>().state.tools.any((tool) {
    return tool.category.trim().toLowerCase() == category.trim().toLowerCase();
  });

  if (isCategoryUsed) {
    showLookupMessage(
      context,
      'Cannot delete category because it is used by tools',
    );
    return;
  }

  context.read<LookupsCubit>().deleteToolCategory(category);

  showLookupMessage(context, 'Category deleted successfully');
}
