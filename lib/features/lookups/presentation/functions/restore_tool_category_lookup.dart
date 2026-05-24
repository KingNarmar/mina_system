import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/functions/show_lookup_message.dart';

Future<bool> restoreToolCategoryLookup({
  required BuildContext context,
  required String category,
}) async {
  final cleanCategory = category.trim();

  if (cleanCategory.isEmpty) {
    showLookupMessage(
      context,
      'Tool category was not found.',
      type: AppMessageType.warning,
    );
    return false;
  }

  final lookupsCubit = context.read<LookupsCubit>();

  final inactiveToolCategoryModel = lookupsCubit
      .state
      .inactiveToolCategoryModels
      .where((item) => _isSameLookupName(item.name, cleanCategory))
      .firstOrNull;

  if (inactiveToolCategoryModel == null) {
    showLookupMessage(
      context,
      'Inactive tool category was not found.',
      type: AppMessageType.warning,
    );
    return false;
  }

  final isRestored = await lookupsCubit.reactivateToolCategory(
    category: cleanCategory,
  );

  if (!context.mounted) {
    return false;
  }

  if (isRestored) {
    showLookupMessage(
      context,
      'Tool category restored successfully.',
      type: AppMessageType.success,
    );
  } else {
    final message =
        lookupsCubit.state.errorMessage ?? 'Tool category was not restored.';
    lookupsCubit.clearErrorMessage();

    showLookupMessage(
      context,
      message,
      type: _toolCategoryRestoreMessageType(message),
    );
  }

  return isRestored;
}

AppMessageType _toolCategoryRestoreMessageType(String message) {
  final normalizedMessage = message.toLowerCase();

  if (normalizedMessage.contains('not found')) {
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
