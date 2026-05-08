import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';
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
            return _saveTool(
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
                return _saveTool(
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

Future<String?> _saveTool({
  required BuildContext context,
  required ToolModel? currentTool,
  required ToolModel savedTool,
}) async {
  final companyId = context.currentCompanyId;
  final profileId = context.currentProfileId;
  final toolsCubit = context.read<ToolsCubit>();
  final dashboardCubit = context.read<DashboardCubit>();

  if (companyId == null || companyId.trim().isEmpty) {
    return 'Company ID was not found';
  }

  if (currentTool == null && (profileId == null || profileId.trim().isEmpty)) {
    return 'Profile ID was not found';
  }

  if (currentTool == null) {
    final isSaved = await toolsCubit.addTool(
      savedTool,
      companyId: companyId,
      createdByProfileId: profileId,
    );

    if (!context.mounted) {
      return 'Unable to save tool.';
    }

    if (!isSaved) {
      final errorMessage =
          toolsCubit.state.errorMessage ?? 'Tool was not added.';
      toolsCubit.clearErrorMessage();
      return errorMessage;
    }

    await dashboardCubit.loadDashboardSummary(companyId: companyId);

    if (context.mounted) {
      AppMessage.showSuccess(context, 'Tool added successfully');
    }

    return null;
  }

  final isSaved = await toolsCubit.updateTool(
    currentToolCode: currentTool.toolCode,
    updatedTool: savedTool,
    companyId: companyId,
  );

  if (!context.mounted) {
    return 'Unable to save tool.';
  }

  if (!isSaved) {
    final errorMessage =
        toolsCubit.state.errorMessage ?? 'Tool was not updated.';
    toolsCubit.clearErrorMessage();
    return errorMessage;
  }

  await dashboardCubit.loadDashboardSummary(companyId: companyId);

  if (context.mounted) {
    AppMessage.showSuccess(context, 'Tool updated successfully');
  }

  return null;
}
