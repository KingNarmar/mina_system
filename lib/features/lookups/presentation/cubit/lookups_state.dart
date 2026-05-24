import 'package:mina_system/features/lookups/data/models/department_model.dart';
import 'package:mina_system/features/lookups/data/models/job_title_model.dart';
import 'package:mina_system/features/lookups/data/models/tool_category_model.dart';
import 'package:mina_system/features/lookups/data/models/tool_unit_model.dart';

class LookupsState {
  const LookupsState({
    required this.departments,
    required this.jobTitlesByDepartment,
    required this.toolUnits,
    required this.toolCategories,
    this.inactiveDepartments = const [],
    this.inactiveJobTitlesByDepartment = const {},
    this.inactiveToolUnits = const [],
    this.inactiveToolCategories = const [],
    this.departmentModels = const [],
    this.jobTitleModels = const [],
    this.toolUnitModels = const [],
    this.toolCategoryModels = const [],
    this.inactiveDepartmentModels = const [],
    this.inactiveJobTitleModels = const [],
    this.inactiveToolUnitModels = const [],
    this.inactiveToolCategoryModels = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final List<String> departments;
  final Map<String, List<String>> jobTitlesByDepartment;
  final List<String> toolUnits;
  final List<String> toolCategories;

  final List<String> inactiveDepartments;
  final Map<String, List<String>> inactiveJobTitlesByDepartment;
  final List<String> inactiveToolUnits;
  final List<String> inactiveToolCategories;

  final List<DepartmentModel> departmentModels;
  final List<JobTitleModel> jobTitleModels;
  final List<ToolUnitModel> toolUnitModels;
  final List<ToolCategoryModel> toolCategoryModels;

  final List<DepartmentModel> inactiveDepartmentModels;
  final List<JobTitleModel> inactiveJobTitleModels;
  final List<ToolUnitModel> inactiveToolUnitModels;
  final List<ToolCategoryModel> inactiveToolCategoryModels;

  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  List<String> getJobTitlesByDepartment(String? department) {
    if (department == null || department.trim().isEmpty) {
      return [];
    }

    return jobTitlesByDepartment[department] ?? [];
  }

  List<String> getInactiveJobTitlesByDepartment(String? department) {
    if (department == null || department.trim().isEmpty) {
      return [];
    }

    return inactiveJobTitlesByDepartment[department] ?? [];
  }

  LookupsState copyWith({
    List<String>? departments,
    Map<String, List<String>>? jobTitlesByDepartment,
    List<String>? toolUnits,
    List<String>? toolCategories,
    List<String>? inactiveDepartments,
    Map<String, List<String>>? inactiveJobTitlesByDepartment,
    List<String>? inactiveToolUnits,
    List<String>? inactiveToolCategories,
    List<DepartmentModel>? departmentModels,
    List<JobTitleModel>? jobTitleModels,
    List<ToolUnitModel>? toolUnitModels,
    List<ToolCategoryModel>? toolCategoryModels,
    List<DepartmentModel>? inactiveDepartmentModels,
    List<JobTitleModel>? inactiveJobTitleModels,
    List<ToolUnitModel>? inactiveToolUnitModels,
    List<ToolCategoryModel>? inactiveToolCategoryModels,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return LookupsState(
      departments: departments ?? this.departments,
      jobTitlesByDepartment:
          jobTitlesByDepartment ?? this.jobTitlesByDepartment,
      toolUnits: toolUnits ?? this.toolUnits,
      toolCategories: toolCategories ?? this.toolCategories,
      inactiveDepartments: inactiveDepartments ?? this.inactiveDepartments,
      inactiveJobTitlesByDepartment:
          inactiveJobTitlesByDepartment ?? this.inactiveJobTitlesByDepartment,
      inactiveToolUnits: inactiveToolUnits ?? this.inactiveToolUnits,
      inactiveToolCategories:
          inactiveToolCategories ?? this.inactiveToolCategories,
      departmentModels: departmentModels ?? this.departmentModels,
      jobTitleModels: jobTitleModels ?? this.jobTitleModels,
      toolUnitModels: toolUnitModels ?? this.toolUnitModels,
      toolCategoryModels: toolCategoryModels ?? this.toolCategoryModels,
      inactiveDepartmentModels:
          inactiveDepartmentModels ?? this.inactiveDepartmentModels,
      inactiveJobTitleModels:
          inactiveJobTitleModels ?? this.inactiveJobTitleModels,
      inactiveToolUnitModels:
          inactiveToolUnitModels ?? this.inactiveToolUnitModels,
      inactiveToolCategoryModels:
          inactiveToolCategoryModels ?? this.inactiveToolCategoryModels,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
