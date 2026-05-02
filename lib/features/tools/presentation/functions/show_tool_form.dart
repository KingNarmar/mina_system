import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';
import 'package:mina_system/features/tools/presentation/functions/show_tool_message.dart';
import 'package:mina_system/features/tools/presentation/widgets/form/add_edit_tool_form.dart';

void showToolBottomSheet(BuildContext context, {ToolModel? tool}) {
  final toolsCubit = context.read<ToolsCubit>();
  final lookupsCubit = context.read<LookupsCubit>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: toolsCubit),
          BlocProvider.value(value: lookupsCubit),
        ],
        child: AddEditToolForm(
          initialTool: tool,
          generatedToolCode: tool == null
              ? toolsCubit.generateNextToolCode()
              : null,
          isToolCodeAlreadyUsed: toolsCubit.isToolCodeAlreadyUsed,
          isToolNameAlreadyUsed: toolsCubit.isToolNameAlreadyUsed,
          onSave: (savedTool) {
            _saveTool(
              context: context,
              currentTool: tool,
              savedTool: savedTool,
            );
          },
        ),
      );
    },
  );
}

void showToolDialog(BuildContext context, {ToolModel? tool}) {
  final toolsCubit = context.read<ToolsCubit>();
  final lookupsCubit = context.read<LookupsCubit>();

  showDialog(
    context: context,
    builder: (_) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: 460,
          child: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: toolsCubit),
              BlocProvider.value(value: lookupsCubit),
            ],
            child: AddEditToolForm(
              initialTool: tool,
              generatedToolCode: tool == null
                  ? toolsCubit.generateNextToolCode()
                  : null,
              isToolCodeAlreadyUsed: toolsCubit.isToolCodeAlreadyUsed,
              isToolNameAlreadyUsed: toolsCubit.isToolNameAlreadyUsed,
              onSave: (savedTool) {
                _saveTool(
                  context: context,
                  currentTool: tool,
                  savedTool: savedTool,
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

void _saveTool({
  required BuildContext context,
  required ToolModel? currentTool,
  required ToolModel savedTool,
}) {
  if (currentTool == null) {
    context.read<ToolsCubit>().addTool(savedTool);
    showToolMessage(context, 'Tool added successfully');
    return;
  }

  context.read<ToolsCubit>().updateTool(
    currentToolCode: currentTool.toolCode,
    updatedTool: savedTool,
  );

  showToolMessage(context, 'Tool updated successfully');
}
