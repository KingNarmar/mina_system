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
        ),
      );

      return true;
    } catch (error) {
      emitState(
        state.copyWith(isSubmitting: false, errorMessage: error.toString()),
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

    emitState(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await _lookupsRepo.deleteToolCategory(
        toolCategoryId: toolCategoryModel.id,
      );

      final updatedToolCategories = state.toolCategoryModels.where((item) {
        return item.id != toolCategoryModel.id;
      }).toList();

      emitState(
        LookupsCubitHelpers.buildStateFromModels(
          departments: state.departmentModels,
          jobTitles: state.jobTitleModels,
          toolUnits: state.toolUnitModels,
          toolCategories: updatedToolCategories,
        ),
      );

      return true;
    } catch (error) {
      emitState(
        state.copyWith(isSubmitting: false, errorMessage: error.toString()),
      );
      return false;
    }
  }
}
