import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/lookups/data/repo/lookups_repo.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit_helpers.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit_initial_data.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_state.dart';
import 'package:mina_system/features/lookups/presentation/functions/lookup_helpers.dart';

class LookupsCubit extends Cubit<LookupsState> {
  LookupsCubit({LookupsRepo? lookupsRepo})
    : _lookupsRepo = lookupsRepo ?? LookupsRepo(),
      super(
        const LookupsState(
          departments: LookupsCubitInitialData.initialDepartments,
          jobTitlesByDepartment:
              LookupsCubitInitialData.initialJobTitlesByDepartment,
          toolUnits: LookupsCubitInitialData.initialToolUnits,
          toolCategories: LookupsCubitInitialData.initialToolCategories,
        ),
      );

  final LookupsRepo _lookupsRepo;

  Future<void> loadLookups({required String companyId}) async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    try {
      final departments = await _lookupsRepo.getDepartments(
        companyId: companyId,
      );

      final jobTitles = await _lookupsRepo.getJobTitles(companyId: companyId);

      final toolUnits = await _lookupsRepo.getToolUnits(companyId: companyId);

      final toolCategories = await _lookupsRepo.getToolCategories(
        companyId: companyId,
      );

      emit(
        LookupsCubitHelpers.buildStateFromModels(
          departments: departments,
          jobTitles: jobTitles,
          toolUnits: toolUnits,
          toolCategories: toolCategories,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  Future<bool> addDepartment({
    required String companyId,
    required String department,
  }) async {
    final cleanDepartment = department.trim();

    if (cleanDepartment.isEmpty) {
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final isDuplicated = await _lookupsRepo.departmentNameExists(
        companyId: companyId,
        name: cleanDepartment,
      );

      if (isDuplicated) {
        emit(
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

      emit(
        LookupsCubitHelpers.buildStateFromModels(
          departments: [...state.departmentModels, addedDepartment],
          jobTitles: state.jobTitleModels,
          toolUnits: state.toolUnitModels,
          toolCategories: state.toolCategoryModels,
        ),
      );

      return true;
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
      return false;
    }
  }

  Future<bool> deleteDepartment({required String departmentId}) async {
    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await _lookupsRepo.deleteDepartment(departmentId: departmentId);

      final updatedDepartments = state.departmentModels.where((department) {
        return department.id != departmentId;
      }).toList();

      final updatedJobTitles = state.jobTitleModels.where((jobTitle) {
        return jobTitle.departmentId != departmentId;
      }).toList();

      emit(
        LookupsCubitHelpers.buildStateFromModels(
          departments: updatedDepartments,
          jobTitles: updatedJobTitles,
          toolUnits: state.toolUnitModels,
          toolCategories: state.toolCategoryModels,
        ),
      );

      return true;
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
      return false;
    }
  }

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
      emit(state.copyWith(errorMessage: 'Department was not found'));
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final isDuplicated = await _lookupsRepo.jobTitleNameExists(
        companyId: companyId,
        departmentId: departmentModel.id,
        name: cleanJobTitle,
      );

      if (isDuplicated) {
        emit(
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

      emit(
        LookupsCubitHelpers.buildStateFromModels(
          departments: state.departmentModels,
          jobTitles: [...state.jobTitleModels, addedJobTitle],
          toolUnits: state.toolUnitModels,
          toolCategories: state.toolCategoryModels,
        ),
      );

      return true;
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
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
      emit(state.copyWith(errorMessage: 'Department was not found'));
      return false;
    }

    final jobTitleModel = state.jobTitleModels.where((item) {
      final isSameDepartment = item.departmentId == departmentModel.id;
      final isSameJobTitle = isSameValue(item.name, cleanJobTitle);

      return isSameDepartment && isSameJobTitle;
    }).firstOrNull;

    if (jobTitleModel == null) {
      emit(state.copyWith(errorMessage: 'Job title was not found'));
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await _lookupsRepo.deleteJobTitle(jobTitleId: jobTitleModel.id);

      final updatedJobTitles = state.jobTitleModels.where((item) {
        return item.id != jobTitleModel.id;
      }).toList();

      emit(
        LookupsCubitHelpers.buildStateFromModels(
          departments: state.departmentModels,
          jobTitles: updatedJobTitles,
          toolUnits: state.toolUnitModels,
          toolCategories: state.toolCategoryModels,
        ),
      );

      return true;
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
      return false;
    }
  }

  Future<bool> addToolUnit({
    required String companyId,
    required String unit,
  }) async {
    final cleanUnit = unit.trim();

    if (cleanUnit.isEmpty) {
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final isDuplicated = await _lookupsRepo.toolUnitNameExists(
        companyId: companyId,
        name: cleanUnit,
      );

      if (isDuplicated) {
        emit(
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

      emit(
        LookupsCubitHelpers.buildStateFromModels(
          departments: state.departmentModels,
          jobTitles: state.jobTitleModels,
          toolUnits: [...state.toolUnitModels, addedToolUnit],
          toolCategories: state.toolCategoryModels,
        ),
      );

      return true;
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
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
      emit(state.copyWith(errorMessage: 'Tool unit was not found'));
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await _lookupsRepo.deleteToolUnit(toolUnitId: toolUnitModel.id);

      final updatedToolUnits = state.toolUnitModels.where((item) {
        return item.id != toolUnitModel.id;
      }).toList();

      emit(
        LookupsCubitHelpers.buildStateFromModels(
          departments: state.departmentModels,
          jobTitles: state.jobTitleModels,
          toolUnits: updatedToolUnits,
          toolCategories: state.toolCategoryModels,
        ),
      );

      return true;
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
      return false;
    }
  }

  Future<bool> addToolCategory({
    required String companyId,
    required String category,
  }) async {
    final cleanCategory = category.trim();

    if (cleanCategory.isEmpty) {
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final isDuplicated = await _lookupsRepo.toolCategoryNameExists(
        companyId: companyId,
        name: cleanCategory,
      );

      if (isDuplicated) {
        emit(
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

      emit(
        LookupsCubitHelpers.buildStateFromModels(
          departments: state.departmentModels,
          jobTitles: state.jobTitleModels,
          toolUnits: state.toolUnitModels,
          toolCategories: [...state.toolCategoryModels, addedToolCategory],
        ),
      );

      return true;
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
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
      emit(state.copyWith(errorMessage: 'Tool category was not found'));
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await _lookupsRepo.deleteToolCategory(
        toolCategoryId: toolCategoryModel.id,
      );

      final updatedToolCategories = state.toolCategoryModels.where((item) {
        return item.id != toolCategoryModel.id;
      }).toList();

      emit(
        LookupsCubitHelpers.buildStateFromModels(
          departments: state.departmentModels,
          jobTitles: state.jobTitleModels,
          toolUnits: state.toolUnitModels,
          toolCategories: updatedToolCategories,
        ),
      );

      return true;
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
      return false;
    }
  }
}
