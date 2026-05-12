import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';

void confirmReactivateTool({
  required BuildContext context,
  required ToolModel tool,
}) {
  final parentContext = context;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Reactivate Tool'),
        content: Text(
          'Are you sure you want to reactivate ${tool.toolName}? '
          'The tool will appear again in active lists.',
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

              final isReactivated = await toolsCubit.reactivateTool(tool: tool);

              if (!isReactivated) {
                return;
              }

              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Tool reactivated successfully'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            },
            child: const Text('Reactivate'),
          ),
        ],
      );
    },
  );
}
