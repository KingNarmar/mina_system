import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/functions/show_lookup_message.dart';

bool addToolUnitLookup({
  required BuildContext context,
  required String unit,
  required List<String> units,
}) {
  final cleanUnit = unit.trim();

  if (cleanUnit.isEmpty) {
    showLookupMessage(context, 'Please enter unit');
    return false;
  }

  final isDuplicated = units.any((item) {
    return item.trim().toLowerCase() == cleanUnit.toLowerCase();
  });

  if (isDuplicated) {
    showLookupMessage(context, 'Unit already exists');
    return false;
  }

  context.read<LookupsCubit>().addToolUnit(cleanUnit);

  showLookupMessage(context, 'Unit added successfully');

  return true;
}