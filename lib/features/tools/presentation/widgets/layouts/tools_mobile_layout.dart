import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/widgets/app_empty_state.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';
import 'package:mina_system/features/tools/presentation/functions/confirm_delete_tool.dart';
import 'package:mina_system/features/tools/presentation/functions/show_tool_form.dart';
import 'package:mina_system/features/tools/presentation/widgets/card/tool_card.dart';
import 'package:mina_system/features/tools/presentation/widgets/tool_search_field.dart';

class ToolsMobileLayout extends StatelessWidget {
  const ToolsMobileLayout({
    super.key,
    required this.tools,
    required this.canCreateTools,
    required this.canUpdateTools,
    required this.canDeleteTools,
  });

  final List<ToolModel> tools;
  final bool canCreateTools;
  final bool canUpdateTools;
  final bool canDeleteTools;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        itemCount: tools.isEmpty ? 2 : tools.length + 1,
        separatorBuilder: (context, index) {
          return const Gap(12);
        },
        itemBuilder: (context, index) {
          if (index == 0) {
            return ToolSearchField(
              onChanged: (value) {
                context.read<ToolsCubit>().searchTools(value);
              },
            );
          }

          if (tools.isEmpty) {
            return AppEmptyState(
              icon: Icons.build_outlined,
              title: 'No tools found',
              message: canCreateTools
                  ? 'Add your first tool type to start recording custody transactions.'
                  : 'No tools are currently available for your company.',
            );
          }

          final tool = tools[index - 1];

          return ToolCard(
            tool: tool,
            onEdit: canUpdateTools
                ? () {
                    showToolBottomSheet(context, tool: tool);
                  }
                : null,
            onDelete: canDeleteTools
                ? () {
                    confirmDeleteTool(context: context, tool: tool);
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
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
