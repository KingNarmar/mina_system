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
      'Please enter category name.',
      type: AppMessageType.warning,
    );
    return false;
  }

  final lookupsCubit = context.read<LookupsCubit>();
  final state = lookupsCubit.state;

  final alreadyActive = state.toolCategoryModels.any((item) {
    return _isSameLookupName(item.name, cleanCategory);
  });

  if (alreadyActive) {
    showLookupMessage(
      context,
      'Tool category already exists.',
      type: AppMessageType.warning,
    );
    return false;
  }

  final alreadyInactive = state.inactiveToolCategoryModels.any((item) {
    return _isSameLookupName(item.name, cleanCategory);
  });

  if (alreadyInactive) {
    showLookupMessage(
      context,
      'Tool category already exists but is inactive. Restore it instead.',
      type: AppMessageType.warning,
    );
    return false;
  }

  final companyId = context.requireCurrentCompanyId();

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
      'Tool category added successfully.',
      type: AppMessageType.success,
    );
  } else {
    final message =
        lookupsCubit.state.errorMessage ?? 'Tool category was not added.';
    lookupsCubit.clearErrorMessage();

    showLookupMessage(
      context,
      message,
      type: _toolCategoryAddMessageType(message),
    );
  }

  return isAdded;
}

AppMessageType _toolCategoryAddMessageType(String message) {
  final normalizedMessage = message.toLowerCase();

  if (normalizedMessage.contains('already exists') ||
      normalizedMessage.contains('restore it instead') ||
      normalizedMessage.contains('not found')) {
    return AppMessageType.warning;
  }

  return AppMessageType.error;
}

bool _isSameLookupName(String firstValue, String secondValue) {
  return _normalizeLookupName(firstValue) == _normalizeLookupName(secondValue);
}

String _normalizeLookupName(String value) {
  return value.trim().toLowerCase().replaceAll(
    RegExp(r'[^\p{L}\p{N}]+', unicode: true),
    '',
  );
}
