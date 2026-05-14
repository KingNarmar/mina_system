import 'package:flutter/material.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/presentation/widgets/dialogs/tool_details_dialog.dart';

void showToolDetailsDialog(BuildContext context, {required ToolModel tool}) {
  final timezone = context.currentCompany?.timezone;

  showDialog(
    context: context,
    builder: (_) {
      return ToolDetailsDialog(tool: tool, timezone: timezone);
    },
  );
}
