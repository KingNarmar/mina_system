part of 'tools_cubit.dart';

extension ToolsCubitUpdate on ToolsCubit {
  Future<bool> updateTool({
    required String currentToolCode,
    required ToolModel updatedTool,
    String? companyId,
  }) async {
    final existingTool = _findToolByCode(currentToolCode);
    final toolId = updatedTool.id ?? existingTool?.id;
    final cleanToolName = updatedTool.toolName.trim();

    if (companyId == null || companyId.isEmpty) {
      emitState(state.copyWith(errorMessage: 'Company ID was not found'));
      return false;
    }

    if (toolId == null || toolId.isEmpty) {
      emitState(state.copyWith(errorMessage: 'Tool ID was not found'));
      return false;
    }

    if (cleanToolName.isEmpty) {
      return false;
    }

    if (updatedTool.unitId == null || updatedTool.categoryId == null) {
      emitState(state.copyWith(errorMessage: 'Unit and category are required'));
      return false;
    }

    final canContinue = await _ensureOnline();
    if (!canContinue) {
      return false;
    }

    emitState(
      state.copyWith(
        isSubmitting: true,
        submittingActionKey: ToolsSubmissionKeys.update(currentToolCode),
        clearErrorMessage: true,
      ),
    );

    try {
      final isDuplicatedToolCode = await _toolsRepo.toolCodeExists(
        companyId: companyId,
        toolCode: updatedTool.toolCode,
        ignoredToolId: toolId,
      );

      if (isDuplicatedToolCode) {
        emitState(
          state.copyWith(
            isSubmitting: false,
            errorMessage: 'Tool code already exists',
          ),
        );
        return false;
      }

      final isDuplicatedToolName = await _toolsRepo.toolNameExists(
        companyId: companyId,
        toolName: cleanToolName,
        ignoredToolId: toolId,
      );

      if (isDuplicatedToolName) {
        emitState(
          state.copyWith(
            isSubmitting: false,
            errorMessage: 'Tool name already exists',
          ),
        );
        return false;
      }

      final toolToUpdate = updatedTool.copyWith(
        id: toolId,
        companyId: companyId,
        toolName: cleanToolName,
      );

      final savedTool = await _toolsRepo.updateTool(
        toolId: toolId,
        tool: toolToUpdate,
      );

      final updatedTools = state.tools.map((tool) {
        if (tool.id == toolId) {
          return savedTool;
        }

        return tool;
      }).toList();

      emitUpdatedTools(updatedTools, isSubmitting: false);

      return true;
    } catch (error) {
      emitState(
        state.copyWith(
          isSubmitting: false,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to update tool. Please try again.',
          ),
        ),
      );
      return false;
    }
  }
}
