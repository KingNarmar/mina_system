import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';
import 'package:mina_system/features/tools/presentation/widgets/form/add_edit_tool_form.dart';

void showToolBottomSheet(BuildContext context, {ToolModel? tool}) {
  final parentContext = context;
  final toolsCubit = context.read<ToolsCubit>();
  final lookupsCubit = context.read<LookupsCubit>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
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
          onSave: (savedTool) async {
            await _saveTool(
              context: parentContext,
              popContext: sheetContext,
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
  final parentContext = context;
  final toolsCubit = context.read<ToolsCubit>();
  final lookupsCubit = context.read<LookupsCubit>();

  showDialog(
    context: context,
    builder: (dialogContext) {
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
              onSave: (savedTool) async {
                await _saveTool(
                  context: parentContext,
                  popContext: dialogContext,
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

Future<void> _saveTool({
  required BuildContext context,
  required BuildContext popContext,
  required ToolModel? currentTool,
  required ToolModel savedTool,
}) async {
  final companyId = context.currentCompanyId;
  final profileId = context.currentProfileId;
  final toolsCubit = context.read<ToolsCubit>();

  final navigator = Navigator.of(popContext);
  final messenger = ScaffoldMessenger.of(context);

  final bool isSaved;

  if (currentTool == null) {
    isSaved = await toolsCubit.addTool(
      savedTool,
      companyId: companyId,
      createdByProfileId: profileId,
    );

    if (!isSaved) {
      return;
    }

    navigator.pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Tool added successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    return;
  }

  isSaved = await toolsCubit.updateTool(
    currentToolCode: currentTool.toolCode,
    updatedTool: savedTool,
    companyId: companyId,
  );

  if (!isSaved) {
    return;
  }

  navigator.pop();
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(
        content: Text('Tool updated successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
}
