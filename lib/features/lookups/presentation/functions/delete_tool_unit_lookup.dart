import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/functions/show_lookup_message.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';

void deleteToolUnitLookup({
  required BuildContext context,
  required String unit,
}) {
  final isUnitUsed = context.read<ToolsCubit>().state.tools.any((tool) {
    return tool.unit.trim().toLowerCase() == unit.trim().toLowerCase();
  });

  if (isUnitUsed) {
    showLookupMessage(
      context,
      'Cannot delete unit because it is used by tools',
    );
    return;
  }

  context.read<LookupsCubit>().deleteToolUnit(unit);

  showLookupMessage(context, 'Unit deleted successfully');
}
