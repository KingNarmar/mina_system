part of 'tools_cubit.dart';

extension ToolsCubitDelete on ToolsCubit {
  Future<bool> deleteTool(ToolModel tool) async {
    final existingTool = tool.id == null
        ? _findToolByCode(tool.toolCode)
        : null;
    final toolId = tool.id ?? existingTool?.id;
    final companyId = tool.companyId ?? existingTool?.companyId;

    if (toolId == null || toolId.isEmpty) {
      emitState(state.copyWith(errorMessage: 'Tool ID was not found'));
      return false;
    }

    if (companyId == null || companyId.isEmpty) {
      emitState(state.copyWith(errorMessage: 'Company ID was not found'));
      return false;
    }

    final canContinue = await _ensureOnline();
    if (!canContinue) {
      return false;
    }

    emitState(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await _toolsRepo.deleteTool(companyId: companyId, toolId: toolId);

      final updatedTools = state.tools.where((item) {
        return item.id != toolId;
      }).toList();

      emitUpdatedTools(updatedTools, isSubmitting: false);

      return true;
    } catch (error) {
      emitState(
        state.copyWith(
          isSubmitting: false,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to deactivate tool. Please try again.',
          ),
        ),
      );
      return false;
    }
  }
}
