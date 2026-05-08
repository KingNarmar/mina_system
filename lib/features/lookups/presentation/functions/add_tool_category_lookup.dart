import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/utils/app_message.dart';
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
    showLookupMessage(
      context,
      'Please enter category',
      type: AppMessageType.warning,
    );
    return false;
  }

  final companyId = context.requireCurrentCompanyId();
  final lookupsCubit = context.read<LookupsCubit>();

  final isAdded = await lookupsCubit.addToolCategory(
    companyId: companyId,
    category: cleanCategory,
  );

  if (!context.mounted) {
    return false;
  }

  if (isAdded) {
    showLookupMessage(
      context,
      'Category added successfully',
      type: AppMessageType.success,
    );
  } else {
    final message = lookupsCubit.state.errorMessage ?? 'Category was not added';
    lookupsCubit.clearErrorMessage();

    showLookupMessage(context, message, type: AppMessageType.error);
  }

  return isAdded;
}
