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

    final inactiveDepartment = state.inactiveDepartmentModels
        .where((item) => isSameValue(item.name, cleanDepartment))
        .firstOrNull;

    if (inactiveDepartment != null) {
      emitState(
        state.copyWith(
          errorMessage:
              'Department already exists but is inactive. Restore it instead.',
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
            fallback: 'Unable to add department. Please try again.',
          ),
        ),
      );
      return false;
    }
  }

  Future<bool> deleteDepartment({required String departmentId}) async {
    final departmentModel = state.departmentModels
        .where((department) => department.id == departmentId)
        .firstOrNull;

    if (departmentModel == null) {
      emitState(state.copyWith(errorMessage: 'Department was not found'));
      return false;
    }

    final canContinue = await _ensureOnline();
    if (!canContinue) {
      return false;
    }

    emitState(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await _lookupsRepo.deleteDepartment(departmentId: departmentId);

      final updatedDepartments = state.departmentModels.where((department) {
        return department.id != departmentId;
      }).toList();

      final deactivatedDepartment = departmentModel.copyWith(isActive: false);

      final updatedInactiveDepartments = [
        ...state.inactiveDepartmentModels.where((department) {
          return department.id != departmentId;
        }),
        deactivatedDepartment,
      ];

      final deactivatedJobTitles = state.jobTitleModels
          .where((jobTitle) {
            return jobTitle.departmentId == departmentId;
          })
          .map((jobTitle) {
            return jobTitle.copyWith(isActive: false);
          })
          .toList();

      final updatedJobTitles = state.jobTitleModels.where((jobTitle) {
        return jobTitle.departmentId != departmentId;
      }).toList();

      final deactivatedJobTitleIds = deactivatedJobTitles.map((jobTitle) {
        return jobTitle.id;
      }).toSet();

      final updatedInactiveJobTitles = [
        ...state.inactiveJobTitleModels.where((jobTitle) {
          return !deactivatedJobTitleIds.contains(jobTitle.id);
        }),
        ...deactivatedJobTitles,
      ];

      emitState(
        LookupsCubitHelpers.buildStateFromModels(
          departments: updatedDepartments,
          jobTitles: updatedJobTitles,
          toolUnits: state.toolUnitModels,
          toolCategories: state.toolCategoryModels,
          inactiveDepartments: updatedInactiveDepartments,
          inactiveJobTitles: updatedInactiveJobTitles,
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
            fallback: 'Unable to delete department. Please try again.',
          ),
        ),
      );
      return false;
    }
  }

  Future<bool> reactivateDepartment({required String department}) async {
    final cleanDepartment = department.trim();

    if (cleanDepartment.isEmpty) {
      return false;
    }

    final departmentModel = state.inactiveDepartmentModels
        .where((item) => isSameValue(item.name, cleanDepartment))
        .firstOrNull;

    if (departmentModel == null) {
      emitState(
        state.copyWith(errorMessage: 'Inactive department was not found'),
      );
      return false;
    }

    final canContinue = await _ensureOnline();
    if (!canContinue) {
      return false;
    }

    emitState(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final restoredDepartment = await _lookupsRepo.reactivateDepartment(
        departmentId: departmentModel.id,
      );

      final updatedInactiveDepartments = state.inactiveDepartmentModels
          .where((item) => item.id != restoredDepartment.id)
          .toList();

      emitState(
        LookupsCubitHelpers.buildStateFromModels(
          departments: [...state.departmentModels, restoredDepartment],
          jobTitles: state.jobTitleModels,
          toolUnits: state.toolUnitModels,
          toolCategories: state.toolCategoryModels,
          inactiveDepartments: updatedInactiveDepartments,
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
            fallback: 'Unable to restore department. Please try again.',
          ),
        ),
      );
      return false;
    }
  }
}
