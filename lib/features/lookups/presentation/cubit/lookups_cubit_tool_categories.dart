part of 'lookups_cubit.dart';

extension LookupsCubitToolCategories on LookupsCubit {
  Future<bool> addToolCategory({
    required String companyId,
    required String category,
  }) async {
    final cleanCategory = category.trim();

    if (cleanCategory.isEmpty) {
      return false;
    }

    final inactiveToolCategory = state.inactiveToolCategoryModels
        .where((item) => isSameValue(item.name, cleanCategory))
        .firstOrNull;

    if (inactiveToolCategory != null) {
      emitState(
        state.copyWith(
          errorMessage:
              'Tool category already exists but is inactive. Restore it instead.',
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
      final isDuplicated = await _lookupsRepo.toolCategoryNameExists(
        companyId: companyId,
        name: cleanCategory,
      );

      if (isDuplicated) {
        emitState(
          state.copyWith(
            isSubmitting: false,
            errorMessage: 'Tool category already exists',
          ),
        );
        return false;
      }

      final addedToolCategory = await _lookupsRepo.addToolCategory(
        companyId: companyId,
        name: cleanCategory,
      );

      emitState(
        LookupsCubitHelpers.buildStateFromModels(
          departments: state.departmentModels,
          jobTitles: state.jobTitleModels,
          toolUnits: state.toolUnitModels,
          toolCategories: [...state.toolCategoryModels, addedToolCategory],
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
            fallback: 'Unable to add tool category. Please try again.',
          ),
        ),
      );
      return false;
    }
  }

  Future<bool> deleteToolCategory({required String category}) async {
    final cleanCategory = category.trim();

    if (cleanCategory.isEmpty) {
      return false;
    }

    final toolCategoryModel = state.toolCategoryModels
        .where((item) => isSameValue(item.name, cleanCategory))
        .firstOrNull;

    if (toolCategoryModel == null) {
      emitState(state.copyWith(errorMessage: 'Tool category was not found'));
      return false;
    }

    final canContinue = await _ensureOnline();
    if (!canContinue) {
      return false;
    }

    emitState(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await _lookupsRepo.deleteToolCategory(
        toolCategoryId: toolCategoryModel.id,
      );

      final updatedToolCategories = state.toolCategoryModels.where((item) {
        return item.id != toolCategoryModel.id;
      }).toList();

      final updatedInactiveToolCategories = [
        ...state.inactiveToolCategoryModels.where((item) {
          return item.id != toolCategoryModel.id;
        }),
        toolCategoryModel.copyWith(isActive: false),
      ];

      emitState(
        LookupsCubitHelpers.buildStateFromModels(
          departments: state.departmentModels,
          jobTitles: state.jobTitleModels,
          toolUnits: state.toolUnitModels,
          toolCategories: updatedToolCategories,
          inactiveDepartments: state.inactiveDepartmentModels,
          inactiveJobTitles: state.inactiveJobTitleModels,
          inactiveToolUnits: state.inactiveToolUnitModels,
          inactiveToolCategories: updatedInactiveToolCategories,
        ),
      );

      return true;
    } catch (error) {
      emitState(
        state.copyWith(
          isSubmitting: false,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to delete tool category. Please try again.',
          ),
        ),
      );
      return false;
    }
  }

  Future<bool> reactivateToolCategory({required String category}) async {
    final cleanCategory = category.trim();

    if (cleanCategory.isEmpty) {
      return false;
    }

    final toolCategoryModel = state.inactiveToolCategoryModels
        .where((item) => isSameValue(item.name, cleanCategory))
        .firstOrNull;

    if (toolCategoryModel == null) {
      emitState(
        state.copyWith(errorMessage: 'Inactive tool category was not found'),
      );
      return false;
    }

    final canContinue = await _ensureOnline();
    if (!canContinue) {
      return false;
    }

    emitState(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final restoredToolCategory = await _lookupsRepo.reactivateToolCategory(
        toolCategoryId: toolCategoryModel.id,
      );

      final updatedInactiveToolCategories = state.inactiveToolCategoryModels
          .where((item) => item.id != restoredToolCategory.id)
          .toList();

      emitState(
        LookupsCubitHelpers.buildStateFromModels(
          departments: state.departmentModels,
          jobTitles: state.jobTitleModels,
          toolUnits: state.toolUnitModels,
          toolCategories: [...state.toolCategoryModels, restoredToolCategory],
          inactiveDepartments: state.inactiveDepartmentModels,
          inactiveJobTitles: state.inactiveJobTitleModels,
          inactiveToolUnits: state.inactiveToolUnitModels,
          inactiveToolCategories: updatedInactiveToolCategories,
        ),
      );

      return true;
    } catch (error) {
      emitState(
        state.copyWith(
          isSubmitting: false,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to restore tool category. Please try again.',
          ),
        ),
      );
      return false;
    }
  }
}
