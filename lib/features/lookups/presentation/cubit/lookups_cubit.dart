import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/lookups/data/models/department_model.dart';
import 'package:mina_system/features/lookups/data/models/job_title_model.dart';
import 'package:mina_system/features/lookups/data/models/tool_category_model.dart';
import 'package:mina_system/features/lookups/data/models/tool_unit_model.dart';
import 'package:mina_system/features/lookups/data/repo/lookups_repo.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_state.dart';
import 'package:mina_system/features/lookups/presentation/functions/lookup_helpers.dart';

class LookupsCubit extends Cubit<LookupsState> {
  LookupsCubit({LookupsRepo? lookupsRepo})
    : _lookupsRepo = lookupsRepo ?? LookupsRepo(),
      super(
        const LookupsState(
          departments: _initialDepartments,
          jobTitlesByDepartment: _initialJobTitlesByDepartment,
          toolUnits: _initialToolUnits,
          toolCategories: _initialToolCategories,
        ),
      );

  final LookupsRepo _lookupsRepo;

  static const List<String> _initialDepartments = [
    'Fabrication',
    'Carpentry',
    'Mechanical',
    'Safety',
    'Painting',
    'Warehouse',
    'Electrical',
    'Operation',
    'Estimation',
    'Accounts',
    'Purchase',
    'IT',
    'HR',
    'Admin',
  ];

  static const Map<String, List<String>> _initialJobTitlesByDepartment = {
    'Fabrication': [
      'HOD Fabrication',
      'Fabrication Supervisor',
      'Welder',
      'Fabricator',
      'Fitter',
      'Helper',
    ],
    'Carpentry': [
      'HOD Carpentry',
      'Carpentry Supervisor',
      'Carpenter',
      'Helper',
    ],
    'Mechanical': [
      'HOD Mechanical',
      'Mechanical Supervisor',
      'Mechanic',
      'Pipe Fitter',
      'Helper',
    ],
    'Safety': ['HOD Safety', 'Safety Officer', 'Safety Assistant'],
    'Painting': ['HOD Painting', 'Painting Supervisor', 'Painter', 'Helper'],
    'Warehouse': [
      'Warehouse Manager',
      'Storekeeper',
      'Warehouse Assistant',
      'Helper',
    ],
    'Electrical': [
      'HOD Electrical',
      'Electrical Supervisor',
      'Electrician',
      'Helper',
    ],
    'Operation': ['HOD Operation', 'Operation Supervisor', 'Foreman', 'Helper'],
    'Estimation': ['HOD Estimation', 'Estimator', 'Estimation Engineer'],
    'Accounts': ['Chief Accountant', 'Accountant', 'Accounts Assistant'],
    'Purchase': ['Purchase Manager', 'Purchaser', 'Purchase Assistant'],
    'IT': ['IT Manager', 'IT Support', 'System Administrator'],
    'HR': ['HR Manager', 'HR Officer', 'HR Assistant'],
    'Admin': ['Admin Manager', 'Admin Assistant', 'Document Controller'],
  };
  static const List<String> _initialToolUnits = ['Each', 'KG', 'MTR'];

  static const List<String> _initialToolCategories = [
    'Power Tools',
    'Welding Tools',
    'Consumables',
    'Measuring Tools',
    'Hand Tools',
    'Safety Tools',
    'Lifting Tools',
    'Electrical Tools',
  ];

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
        _buildStateFromModels(
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
        _buildStateFromModels(
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
        _buildStateFromModels(
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
        _buildStateFromModels(
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
        _buildStateFromModels(
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
        _buildStateFromModels(
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
        _buildStateFromModels(
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
        _buildStateFromModels(
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
        _buildStateFromModels(
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

  LookupsState _buildStateFromModels({
    required List<DepartmentModel> departments,
    required List<JobTitleModel> jobTitles,
    required List<ToolUnitModel> toolUnits,
    required List<ToolCategoryModel> toolCategories,
    bool isLoading = false,
    bool isSubmitting = false,
    String? errorMessage,
  }) {
    final departmentNames = departments.map((department) {
      return department.name;
    }).toList();

    final jobTitlesByDepartment = <String, List<String>>{};

    for (final department in departments) {
      final departmentJobTitles = jobTitles
          .where((jobTitle) {
            return jobTitle.departmentId == department.id;
          })
          .map((jobTitle) {
            return jobTitle.name;
          })
          .toList();

      jobTitlesByDepartment[department.name] = departmentJobTitles;
    }

    final toolUnitNames = toolUnits.map((toolUnit) {
      return toolUnit.name;
    }).toList();

    final toolCategoryNames = toolCategories.map((toolCategory) {
      return toolCategory.name;
    }).toList();

    return LookupsState(
      departments: departmentNames,
      jobTitlesByDepartment: jobTitlesByDepartment,
      toolUnits: toolUnitNames,
      toolCategories: toolCategoryNames,
      departmentModels: departments,
      jobTitleModels: jobTitles,
      toolUnitModels: toolUnits,
      toolCategoryModels: toolCategories,
      isLoading: isLoading,
      isSubmitting: isSubmitting,
      errorMessage: errorMessage,
    );
  }
}
