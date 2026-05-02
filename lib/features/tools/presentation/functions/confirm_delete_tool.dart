import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';
import 'package:mina_system/features/tools/presentation/functions/show_tool_message.dart';

void confirmDeleteTool({
  required BuildContext context,
  required ToolModel tool,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Delete Tool'),
        content: Text('Are you sure you want to delete ${tool.toolName}?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);

              if (tool.activeCustodyCount > 0) {
                showToolMessage(
                  context,
                  'Cannot delete tool because it has active custody',
                );
                return;
              }

              context.read<ToolsCubit>().deleteTool(tool);
              showToolMessage(context, 'Tool deleted successfully');
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
