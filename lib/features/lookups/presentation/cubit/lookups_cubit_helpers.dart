import 'package:mina_system/features/lookups/data/models/department_model.dart';
import 'package:mina_system/features/lookups/data/models/job_title_model.dart';
import 'package:mina_system/features/lookups/data/models/tool_category_model.dart';
import 'package:mina_system/features/lookups/data/models/tool_unit_model.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_state.dart';

class LookupsCubitHelpers {
  static LookupsState buildStateFromModels({
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
