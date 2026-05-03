import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';
import 'package:mina_system/features/tools/presentation/functions/show_tool_message.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';

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

              final hasTransactions = context
                  .read<TransactionsCubit>()
                  .hasToolTransactions(tool.toolCode);

              if (hasTransactions) {
                showToolMessage(
                  context,
                  'Cannot delete tool because this tool has custody transactions.',
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
