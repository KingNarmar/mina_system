import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/widgets/app_empty_state.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';
import 'package:mina_system/features/tools/presentation/functions/confirm_delete_tool.dart';
import 'package:mina_system/features/tools/presentation/functions/show_tool_form.dart';
import 'package:mina_system/features/tools/presentation/widgets/tool_search_field.dart';
import 'package:mina_system/features/tools/presentation/widgets/tools_table.dart';

class ToolsDesktopLayout extends StatelessWidget {
  const ToolsDesktopLayout({
    super.key,
    required this.tools,
    required this.searchQuery,
    required this.canCreateTools,
    required this.canUpdateTools,
    required this.canDeleteTools,
  });

  final List<ToolModel> tools;
  final String searchQuery;
  final bool canCreateTools;
  final bool canUpdateTools;
  final bool canDeleteTools;

  @override
  Widget build(BuildContext context) {
    final canShowActions = canUpdateTools || canDeleteTools;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ToolSearchField(
                  initialQuery: searchQuery,
                  onChanged: (value) {
                    context.read<ToolsCubit>().searchTools(value);
                  },
                ),
              ),
              if (canCreateTools) ...[
                const Gap(16),
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
            ],
          ),
          const Gap(16),
          if (tools.isEmpty)
            AppEmptyState(
              icon: Icons.build_outlined,
              title: 'No tools found',
              message: canCreateTools
                  ? 'Add your first tool type to start recording custody transactions.'
                  : 'No tools are currently available for your company.',
            )
          else
            SizedBox(
              width: double.infinity,
              child: ToolsTable(
                tools: tools,
                showActions: canShowActions,
                onEdit: canUpdateTools
                    ? (tool) {
                        showToolDialog(context, tool: tool);
                      }
                    : null,
                onDelete: canDeleteTools
                    ? (tool) {
                        confirmDeleteTool(context: context, tool: tool);
                      }
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}
