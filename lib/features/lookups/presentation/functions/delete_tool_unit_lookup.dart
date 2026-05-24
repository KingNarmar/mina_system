import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/functions/show_lookup_message.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';

Future<bool> deleteToolUnitLookup({
  required BuildContext context,
  required String unit,
}) async {
  final cleanUnit = unit.trim();

  final lookupsCubit = context.read<LookupsCubit>();

  final toolUnitModel = lookupsCubit.state.toolUnitModels
      .where((item) => _isSameLookupName(item.name, cleanUnit))
      .firstOrNull;

  if (toolUnitModel == null) {
    showLookupMessage(
      context,
      'Tool unit was not found.',
      type: AppMessageType.warning,
    );
    return false;
  }

  final isUnitUsed = context.read<ToolsCubit>().state.tools.any((tool) {
    return _isSameLookupName(tool.unit, cleanUnit);
  });

  if (isUnitUsed) {
    showLookupMessage(
      context,
      'This tool unit is used by tools and cannot be deactivated.',
      type: AppMessageType.warning,
    );
    return false;
  }

  final isDeleted = await lookupsCubit.deleteToolUnit(unit: cleanUnit);

  if (!context.mounted) {
    return false;
  }

  if (isDeleted) {
    showLookupMessage(
      context,
      'Tool unit deactivated successfully.',
      type: AppMessageType.success,
    );
  } else {
    final message =
        lookupsCubit.state.errorMessage ?? 'Tool unit was not deactivated.';
    lookupsCubit.clearErrorMessage();

    showLookupMessage(context, message, type: AppMessageType.error);
  }

  return isDeleted;
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
