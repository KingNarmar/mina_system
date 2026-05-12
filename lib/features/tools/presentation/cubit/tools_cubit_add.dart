part of 'tools_cubit.dart';

extension ToolsCubitAdd on ToolsCubit {
  Future<bool> addTool(ToolModel tool, {String? companyId}) async {
    final cleanToolName = tool.toolName.trim();

    if (companyId == null || companyId.isEmpty) {
      emitState(state.copyWith(errorMessage: 'Company ID was not found'));
      return false;
    }

    if (cleanToolName.isEmpty) {
      return false;
    }

    if (tool.unitId == null || tool.categoryId == null) {
      emitState(state.copyWith(errorMessage: 'Unit and category are required'));
      return false;
    }

    final canContinue = await _ensureOnline();
    if (!canContinue) {
      return false;
    }

    emitState(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final isDuplicatedToolName = await _toolsRepo.toolNameExists(
        companyId: companyId,
        toolName: cleanToolName,
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

      final toolCode = await _toolsRepo.generateNextToolCode(
        companyId: companyId,
      );

      final isDuplicatedToolCode = await _toolsRepo.toolCodeExists(
        companyId: companyId,
        toolCode: toolCode,
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

      final toolToInsert = tool.copyWith(
        companyId: companyId,
        toolCode: toolCode,
        toolName: cleanToolName,
        status: 'active',
      );

      final addedTool = await _toolsRepo.addTool(tool: toolToInsert);

      emitUpdatedTools([...state.tools, addedTool], isSubmitting: false);

      return true;
    } catch (error) {
      emitState(
        state.copyWith(
          isSubmitting: false,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to add tool. Please try again.',
          ),
        ),
      );
      return false;
    }
  }
}
