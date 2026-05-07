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
            errorMessage: 'Tool unit already exists',
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

  Future<bool> deleteToolUnit({required String unit}) async {
    final cleanUnit = unit.trim();

    if (cleanUnit.isEmpty) {
      return false;
    }

    final toolUnitModel = state.toolUnitModels
        .where((item) => isSameValue(item.name, cleanUnit))
        .firstOrNull;

    if (toolUnitModel == null) {
      emitState(state.copyWith(errorMessage: 'Tool unit was not found'));
      return false;
    }

    emitState(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await _lookupsRepo.deleteToolUnit(toolUnitId: toolUnitModel.id);

      final updatedToolUnits = state.toolUnitModels.where((item) {
        return item.id != toolUnitModel.id;
      }).toList();

      emitState(
        LookupsCubitHelpers.buildStateFromModels(
          departments: state.departmentModels,
          jobTitles: state.jobTitleModels,
          toolUnits: updatedToolUnits,
          toolCategories: state.toolCategoryModels,
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
