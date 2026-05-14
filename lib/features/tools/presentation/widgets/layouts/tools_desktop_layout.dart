import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/widgets/app_empty_state.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';
import 'package:mina_system/features/tools/presentation/functions/confirm_delete_tool.dart';
import 'package:mina_system/features/tools/presentation/functions/confirm_reactivate_tool.dart';
import 'package:mina_system/features/tools/presentation/functions/show_tool_audit_history.dart';
import 'package:mina_system/features/tools/presentation/functions/show_tool_details_dialog.dart';
import 'package:mina_system/features/tools/presentation/functions/show_tool_form.dart';
import 'package:mina_system/features/tools/presentation/widgets/tool_search_field.dart';
import 'package:mina_system/features/tools/presentation/widgets/tools_table.dart';

class ToolsDesktopLayout extends StatelessWidget {
  const ToolsDesktopLayout({
    super.key,
    required this.tools,
    required this.searchQuery,
    required this.statusFilter,
    required this.onStatusFilterChanged,
    required this.canCreateTools,
    required this.canUpdateTools,
    required this.canDeleteTools,
  });

  final List<ToolModel> tools;
  final String searchQuery;
  final String statusFilter;
  final ValueChanged<String> onStatusFilterChanged;
  final bool canCreateTools;
  final bool canUpdateTools;
  final bool canDeleteTools;

  @override
  Widget build(BuildContext context) {
    final isActiveFilter = statusFilter == 'active';
    final canShowActions = true;

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
          const Gap(12),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Active'),
                  selected: statusFilter == 'active',
                  onSelected: (_) {
                    onStatusFilterChanged('active');
                  },
                ),
                ChoiceChip(
                  label: const Text('Inactive'),
                  selected: statusFilter == 'inactive',
                  onSelected: (_) {
                    onStatusFilterChanged('inactive');
                  },
                ),
              ],
            ),
          ),
          const Gap(16),
          if (tools.isEmpty)
            AppEmptyState(
              icon: Icons.build_outlined,
              title: isActiveFilter
                  ? 'No active tools found'
                  : 'No inactive tools found',
              message: isActiveFilter
                  ? canCreateTools
                        ? 'Add your first tool type to start recording custody transactions.'
                        : 'No active tools are currently available for your company.'
                  : 'Deactivated tools will appear here.',
            )
          else
            SizedBox(
              width: double.infinity,
              child: ToolsTable(
                tools: tools,
                showActions: canShowActions,
                onViewDetails: (tool) {
                  showToolDetailsDialog(context, tool: tool);
                },
                onViewAuditHistory: (tool) {
                  showToolAuditHistory(context, tool: tool);
                },
                onEdit: canUpdateTools
                    ? (tool) {
                        showToolDialog(context, tool: tool);
                      }
                    : null,
                onDelete: canDeleteTools && isActiveFilter
                    ? (tool) {
                        confirmDeleteTool(context: context, tool: tool);
                      }
                    : null,
                onReactivate: canDeleteTools && !isActiveFilter
                    ? (tool) {
                        confirmReactivateTool(context: context, tool: tool);
                      }
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}
