import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';

void confirmDeleteTool({
  required BuildContext context,
  required ToolModel tool,
}) {
  final parentContext = context;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Deactivate Tool'),
        content: Text(
          'Are you sure you want to deactivate ${tool.toolName}? '
          'The tool will be hidden from active lists, but existing records will remain safe.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              final messenger = ScaffoldMessenger.of(parentContext);
              final toolsCubit = parentContext.read<ToolsCubit>();

              navigator.pop();

              final isDeactivated = await toolsCubit.deleteTool(tool);

              if (!isDeactivated) {
                return;
              }

              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Tool deactivated successfully'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            },
            child: const Text('Deactivate'),
          ),
        ],
      );
    },
  );
}
