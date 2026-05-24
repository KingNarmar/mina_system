import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/functions/show_lookup_message.dart';

Future<bool> restoreToolUnitLookup({
  required BuildContext context,
  required String unit,
}) async {
  final cleanUnit = unit.trim();

  if (cleanUnit.isEmpty) {
    showLookupMessage(
      context,
      'Tool unit was not found.',
      type: AppMessageType.warning,
    );
    return false;
  }

  final lookupsCubit = context.read<LookupsCubit>();

  final inactiveToolUnitModel = lookupsCubit.state.inactiveToolUnitModels
      .where((item) => _isSameLookupName(item.name, cleanUnit))
      .firstOrNull;

  if (inactiveToolUnitModel == null) {
    showLookupMessage(
      context,
      'Inactive tool unit was not found.',
      type: AppMessageType.warning,
    );
    return false;
  }

  final isRestored = await lookupsCubit.reactivateToolUnit(unit: cleanUnit);

  if (!context.mounted) {
    return false;
  }

  if (isRestored) {
    showLookupMessage(
      context,
      'Tool unit restored successfully.',
      type: AppMessageType.success,
    );
  } else {
    final message =
        lookupsCubit.state.errorMessage ?? 'Tool unit was not restored.';
    lookupsCubit.clearErrorMessage();

    showLookupMessage(
      context,
      message,
      type: _toolUnitRestoreMessageType(message),
    );
  }

  return isRestored;
}

AppMessageType _toolUnitRestoreMessageType(String message) {
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
