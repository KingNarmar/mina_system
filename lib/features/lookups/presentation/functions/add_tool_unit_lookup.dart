import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/functions/show_lookup_message.dart';

Future<bool> addToolUnitLookup({
  required BuildContext context,
  required String unit,
  required List<String> units,
}) async {
  final cleanUnit = unit.trim();

  if (cleanUnit.isEmpty) {
    showLookupMessage(context, 'Please enter unit');
    return false;
  }

  final companyId = context.requireCurrentCompanyId();

  final isAdded = await context.read<LookupsCubit>().addToolUnit(
    companyId: companyId,
    unit: cleanUnit,
  );

  if (!context.mounted) {
    return false;
  }

  if (isAdded) {
    showLookupMessage(context, 'Unit added successfully');
  } else {
    showLookupMessage(context, 'Unit was not added');
  }

  return isAdded;
}
