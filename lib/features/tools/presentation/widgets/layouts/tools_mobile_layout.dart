import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/widgets/app_empty_state.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';
import 'package:mina_system/features/tools/presentation/functions/confirm_delete_tool.dart';
import 'package:mina_system/features/tools/presentation/functions/confirm_reactivate_tool.dart';
import 'package:mina_system/features/tools/presentation/functions/show_tool_audit_history.dart';
import 'package:mina_system/features/tools/presentation/functions/show_tool_form.dart';
import 'package:mina_system/features/tools/presentation/widgets/card/tool_card.dart';
import 'package:mina_system/features/tools/presentation/widgets/tool_search_field.dart';
import 'package:mina_system/core/theme/app_icons.dart';

class ToolsMobileLayout extends StatelessWidget {
  const ToolsMobileLayout({
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
    final timezone = context.currentCompany?.timezone;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        itemCount: tools.isEmpty ? 3 : tools.length + 2,
        separatorBuilder: (context, index) {
          return const Gap(12);
        },
        itemBuilder: (context, index) {
          if (index == 0) {
            return ToolSearchField(
              initialQuery: searchQuery,
              onChanged: (value) {
                context.read<ToolsCubit>().searchTools(value);
              },
            );
          }

          if (index == 1) {
            return _ToolStatusFilter(
              selectedStatus: statusFilter,
              onChanged: onStatusFilterChanged,
            );
          }

          if (tools.isEmpty) {
            return AppEmptyState(
              icon: AppIcons.tool,
              title: isActiveFilter
                  ? 'No active tools found'
                  : 'No inactive tools found',
              message: isActiveFilter
                  ? canCreateTools
                        ? 'Add your first tool type to start recording custody transactions.'
                        : 'No active tools are currently available for your company.'
                  : 'Deactivated tools will appear here.',
            );
          }

          final tool = tools[index - 2];

          return ToolCard(
            tool: tool,
            timezone: timezone,
            onViewAuditHistory: () {
              showToolAuditHistory(context, tool: tool);
            },
            onEdit: canUpdateTools
                ? () {
                    showToolBottomSheet(context, tool: tool);
                  }
                : null,
            onDelete: canDeleteTools && isActiveFilter
                ? () {
                    confirmDeleteTool(context: context, tool: tool);
                  }
                : null,
            onReactivate: canDeleteTools && !isActiveFilter
                ? () {
                    confirmReactivateTool(context: context, tool: tool);
                  }
                : null,
          );
        },
      ),
      floatingActionButton: canCreateTools
          ? FloatingActionButton(
              onPressed: () {
                showToolBottomSheet(context);
              },
              child: const Icon(AppIcons.add),
            )
          : null,
    );
  }
}

class _ToolStatusFilter extends StatelessWidget {
  const _ToolStatusFilter({
    required this.selectedStatus,
    required this.onChanged,
  });

  final String selectedStatus;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: const Text('Active'),
          selected: selectedStatus == 'active',
          onSelected: (_) {
            onChanged('active');
          },
        ),
        ChoiceChip(
          label: const Text('Inactive'),
          selected: selectedStatus == 'inactive',
          onSelected: (_) {
            onChanged('inactive');
          },
        ),
      ],
    );
  }
}
