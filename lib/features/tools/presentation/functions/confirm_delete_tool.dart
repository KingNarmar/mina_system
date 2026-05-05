import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';

void confirmDeleteTool({
  required BuildContext context,
  required ToolModel tool,
}) {
  final parentContext = context;

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
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              final messenger = ScaffoldMessenger.of(parentContext);
              final toolsCubit = parentContext.read<ToolsCubit>();

              navigator.pop();

              final hasTransactions = parentContext
                  .read<TransactionsCubit>()
                  .hasToolTransactions(tool.toolCode);

              if (hasTransactions) {
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Cannot delete tool because this tool has custody transactions.',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                return;
              }

              final isDeleted = await toolsCubit.deleteTool(tool);

              if (!isDeleted) {
                return;
              }

              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Tool deleted successfully'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
