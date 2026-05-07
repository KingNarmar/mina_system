part of 'lookups_cubit.dart';

extension LookupsCubitDepartments on LookupsCubit {
  Future<bool> addDepartment({
    required String companyId,
    required String department,
  }) async {
    final cleanDepartment = department.trim();

    if (cleanDepartment.isEmpty) {
      return false;
    }

    emitState(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final isDuplicated = await _lookupsRepo.departmentNameExists(
        companyId: companyId,
        name: cleanDepartment,
      );

      if (isDuplicated) {
        emitState(
          state.copyWith(
            isSubmitting: false,
            errorMessage: 'Department already exists',
          ),
        );
        return false;
      }

      final addedDepartment = await _lookupsRepo.addDepartment(
        companyId: companyId,
        name: cleanDepartment,
      );

      emitState(
        LookupsCubitHelpers.buildStateFromModels(
          departments: [...state.departmentModels, addedDepartment],
          jobTitles: state.jobTitleModels,
          toolUnits: state.toolUnitModels,
          toolCategories: state.toolCategoryModels,
        ),
      );

      return true;
    } catch (error) {
      emitState(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
      return false;
    }
  }

  Future<bool> deleteDepartment({required String departmentId}) async {
    emitState(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await _lookupsRepo.deleteDepartment(departmentId: departmentId);

      final updatedDepartments = state.departmentModels.where((department) {
        return department.id != departmentId;
      }).toList();

      final updatedJobTitles = state.jobTitleModels.where((jobTitle) {
        return jobTitle.departmentId != departmentId;
      }).toList();

      emitState(
        LookupsCubitHelpers.buildStateFromModels(
          departments: updatedDepartments,
          jobTitles: updatedJobTitles,
          toolUnits: state.toolUnitModels,
          toolCategories: state.toolCategoryModels,
        ),
      );

      return true;
    } catch (error) {
      emitState(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
      return false;
    }
  }
}
