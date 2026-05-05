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
    this.departmentModels = const [],
    this.jobTitleModels = const [],
    this.toolUnitModels = const [],
    this.toolCategoryModels = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final List<String> departments;
  final Map<String, List<String>> jobTitlesByDepartment;
  final List<String> toolUnits;
  final List<String> toolCategories;

  final List<DepartmentModel> departmentModels;
  final List<JobTitleModel> jobTitleModels;
  final List<ToolUnitModel> toolUnitModels;
  final List<ToolCategoryModel> toolCategoryModels;

  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  List<String> getJobTitlesByDepartment(String? department) {
    if (department == null || department.trim().isEmpty) {
      return [];
    }

    return jobTitlesByDepartment[department] ?? [];
  }

  LookupsState copyWith({
    List<String>? departments,
    Map<String, List<String>>? jobTitlesByDepartment,
    List<String>? toolUnits,
    List<String>? toolCategories,
    List<DepartmentModel>? departmentModels,
    List<JobTitleModel>? jobTitleModels,
    List<ToolUnitModel>? toolUnitModels,
    List<ToolCategoryModel>? toolCategoryModels,
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
      departmentModels: departmentModels ?? this.departmentModels,
      jobTitleModels: jobTitleModels ?? this.jobTitleModels,
      toolUnitModels: toolUnitModels ?? this.toolUnitModels,
      toolCategoryModels: toolCategoryModels ?? this.toolCategoryModels,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
