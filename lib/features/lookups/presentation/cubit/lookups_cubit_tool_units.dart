part of 'lookups_cubit.dart';

extension LookupsCubitToolUnits on LookupsCubit {
  Future<bool> addToolUnit({
    required String companyId,
    required String unit,
  }) async {
    final cleanUnit = unit.trim();

    if (cleanUnit.isEmpty) {
      return false;
    }

    final inactiveToolUnit = state.inactiveToolUnitModels
        .where((item) => isSameValue(item.name, cleanUnit))
        .firstOrNull;

    if (inactiveToolUnit != null) {
      emitState(
        state.copyWith(
          errorMessage:
              'Tool unit already exists but is inactive. Restore it instead.',
        ),
      );
      return false;
    }

    final canContinue = await _ensureOnline();
    if (!canContinue) {
      return false;
    }

    emitState(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final isDuplicated = await _lookupsRepo.toolUnitNameExists(
        companyId: companyId,
        name: cleanUnit,
      );

      if (isDuplicated) {
        emitState(
          state.copyWith(
            isSubmitting: false,
            errorMessage: 'Tool unit already exists.',
          ),
        );
        return false;
      }

      final addedToolUnit = await _lookupsRepo.addToolUnit(
        companyId: companyId,
        name: cleanUnit,
      );

      emitState(
        LookupsCubitHelpers.buildStateFromModels(
          departments: state.departmentModels,
          jobTitles: state.jobTitleModels,
          toolUnits: [...state.toolUnitModels, addedToolUnit],
          toolCategories: state.toolCategoryModels,
          inactiveDepartments: state.inactiveDepartmentModels,
          inactiveJobTitles: state.inactiveJobTitleModels,
          inactiveToolUnits: state.inactiveToolUnitModels,
          inactiveToolCategories: state.inactiveToolCategoryModels,
        ),
      );

      return true;
    } catch (error) {
      emitState(
        state.copyWith(
          isSubmitting: false,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to add tool unit. Please try again.',
          ),
        ),
      );
      return false;
    }
  }

  Future<bool> deleteToolUnit({required String unit}) async {
    final cleanUnit = unit.trim();

    if (cleanUnit.isEmpty) {
      return false;
    }

    final toolUnitModel = state.toolUnitModels
        .where((item) => isSameValue(item.name, cleanUnit))
        .firstOrNull;

    if (toolUnitModel == null) {
      emitState(state.copyWith(errorMessage: 'Tool unit was not found.'));
      return false;
    }

    final canContinue = await _ensureOnline();
    if (!canContinue) {
      return false;
    }

    emitState(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await _lookupsRepo.deleteToolUnit(toolUnitId: toolUnitModel.id);

      final updatedToolUnits = state.toolUnitModels.where((item) {
        return item.id != toolUnitModel.id;
      }).toList();

      final updatedInactiveToolUnits = [
        ...state.inactiveToolUnitModels.where((item) {
          return item.id != toolUnitModel.id;
        }),
        toolUnitModel.copyWith(isActive: false),
      ];

      emitState(
        LookupsCubitHelpers.buildStateFromModels(
          departments: state.departmentModels,
          jobTitles: state.jobTitleModels,
          toolUnits: updatedToolUnits,
          toolCategories: state.toolCategoryModels,
          inactiveDepartments: state.inactiveDepartmentModels,
          inactiveJobTitles: state.inactiveJobTitleModels,
          inactiveToolUnits: updatedInactiveToolUnits,
          inactiveToolCategories: state.inactiveToolCategoryModels,
        ),
      );

      return true;
    } catch (error) {
      emitState(
        state.copyWith(
          isSubmitting: false,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to deactivate tool unit. Please try again.',
          ),
        ),
      );
      return false;
    }
  }

  Future<bool> reactivateToolUnit({required String unit}) async {
    final cleanUnit = unit.trim();

    if (cleanUnit.isEmpty) {
      return false;
    }

    final toolUnitModel = state.inactiveToolUnitModels
        .where((item) => isSameValue(item.name, cleanUnit))
        .firstOrNull;

    if (toolUnitModel == null) {
      emitState(
        state.copyWith(errorMessage: 'Inactive tool unit was not found.'),
      );
      return false;
    }

    final canContinue = await _ensureOnline();
    if (!canContinue) {
      return false;
    }

    emitState(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final restoredToolUnit = await _lookupsRepo.reactivateToolUnit(
        toolUnitId: toolUnitModel.id,
      );

      final updatedInactiveToolUnits = state.inactiveToolUnitModels
          .where((item) => item.id != restoredToolUnit.id)
          .toList();

      emitState(
        LookupsCubitHelpers.buildStateFromModels(
          departments: state.departmentModels,
          jobTitles: state.jobTitleModels,
          toolUnits: [...state.toolUnitModels, restoredToolUnit],
          toolCategories: state.toolCategoryModels,
          inactiveDepartments: state.inactiveDepartmentModels,
          inactiveJobTitles: state.inactiveJobTitleModels,
          inactiveToolUnits: updatedInactiveToolUnits,
          inactiveToolCategories: state.inactiveToolCategoryModels,
        ),
      );

      return true;
    } catch (error) {
      emitState(
        state.copyWith(
          isSubmitting: false,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to restore tool unit. Please try again.',
          ),
        ),
      );
      return false;
    }
  }
}
