class LookupsState {
  const LookupsState({
    required this.departments,
    required this.jobTitlesByDepartment,
    required this.toolUnits,
    required this.toolCategories,
  });

  final List<String> departments;
  final Map<String, List<String>> jobTitlesByDepartment;
  final List<String> toolUnits;
  final List<String> toolCategories;

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
  }) {
    return LookupsState(
      departments: departments ?? this.departments,
      jobTitlesByDepartment:
          jobTitlesByDepartment ?? this.jobTitlesByDepartment,
      toolUnits: toolUnits ?? this.toolUnits,
      toolCategories: toolCategories ?? this.toolCategories,
    );
  }
}
