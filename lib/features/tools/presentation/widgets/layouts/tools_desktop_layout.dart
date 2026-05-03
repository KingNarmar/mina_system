import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/widgets/app_empty_state.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';
import 'package:mina_system/features/tools/presentation/functions/confirm_delete_tool.dart';
import 'package:mina_system/features/tools/presentation/functions/show_tool_form.dart';
import 'package:mina_system/features/tools/presentation/widgets/tool_search_field.dart';
import 'package:mina_system/features/tools/presentation/widgets/tools_table.dart';

class ToolsDesktopLayout extends StatelessWidget {
  const ToolsDesktopLayout({super.key, required this.tools});

  final List<ToolModel> tools;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ToolSearchField(
                  onChanged: (value) {
                    context.read<ToolsCubit>().searchTools(value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showToolDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Tool'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (tools.isEmpty)
            const AppEmptyState(
              icon: Icons.build_outlined,
              title: 'No tools found',
              message:
                  'Add your first tool type to start recording custody transactions.',
            )
          else
            SizedBox(
              width: double.infinity,
              child: ToolsTable(
                tools: tools,
                onEdit: (tool) {
                  showToolDialog(context, tool: tool);
                },
                onDelete: (tool) {
                  confirmDeleteTool(context: context, tool: tool);
                },
              ),
            ),
        ],
      ),
    );
  }
}
