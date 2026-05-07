part of 'lookups_cubit.dart';

extension LookupsCubitJobTitles on LookupsCubit {
  Future<bool> addJobTitle({
    required String companyId,
    required String department,
    required String jobTitle,
  }) async {
    final cleanDepartment = department.trim();
    final cleanJobTitle = jobTitle.trim();

    if (cleanDepartment.isEmpty || cleanJobTitle.isEmpty) {
      return false;
    }

    final departmentModel = state.departmentModels
        .where((item) => isSameValue(item.name, cleanDepartment))
        .firstOrNull;

    if (departmentModel == null) {
      emitState(state.copyWith(errorMessage: 'Department was not found'));
      return false;
    }

    emitState(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final isDuplicated = await _lookupsRepo.jobTitleNameExists(
        companyId: companyId,
        departmentId: departmentModel.id,
        name: cleanJobTitle,
      );

      if (isDuplicated) {
        emitState(
          state.copyWith(
            isSubmitting: false,
            errorMessage: 'Job title already exists',
          ),
        );
        return false;
      }

      final addedJobTitle = await _lookupsRepo.addJobTitle(
        companyId: companyId,
        departmentId: departmentModel.id,
        name: cleanJobTitle,
      );

      emitState(
        LookupsCubitHelpers.buildStateFromModels(
          departments: state.departmentModels,
          jobTitles: [...state.jobTitleModels, addedJobTitle],
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

  Future<bool> deleteJobTitle({
    required String department,
    required String jobTitle,
  }) async {
    final cleanDepartment = department.trim();
    final cleanJobTitle = jobTitle.trim();

    if (cleanDepartment.isEmpty || cleanJobTitle.isEmpty) {
      return false;
    }

    final departmentModel = state.departmentModels
        .where((item) => isSameValue(item.name, cleanDepartment))
        .firstOrNull;

    if (departmentModel == null) {
      emitState(state.copyWith(errorMessage: 'Department was not found'));
      return false;
    }

    final jobTitleModel = state.jobTitleModels.where((item) {
      final isSameDepartment = item.departmentId == departmentModel.id;
      final isSameJobTitle = isSameValue(item.name, cleanJobTitle);

      return isSameDepartment && isSameJobTitle;
    }).firstOrNull;

    if (jobTitleModel == null) {
      emitState(state.copyWith(errorMessage: 'Job title was not found'));
      return false;
    }

    emitState(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await _lookupsRepo.deleteJobTitle(jobTitleId: jobTitleModel.id);

      final updatedJobTitles = state.jobTitleModels.where((item) {
        return item.id != jobTitleModel.id;
      }).toList();

      emitState(
        LookupsCubitHelpers.buildStateFromModels(
          departments: state.departmentModels,
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
