class LookupsState {
  const LookupsState({
    required this.departments,
    required this.jobTitlesByDepartment,
  });

  final List<String> departments;
  final Map<String, List<String>> jobTitlesByDepartment;

  List<String> getJobTitlesByDepartment(String? department) {
    if (department == null || department.trim().isEmpty) {
      return [];
    }

    return jobTitlesByDepartment[department] ?? [];
  }

  LookupsState copyWith({
    List<String>? departments,
    Map<String, List<String>>? jobTitlesByDepartment,
  }) {
    return LookupsState(
      departments: departments ?? this.departments,
      jobTitlesByDepartment:
          jobTitlesByDepartment ?? this.jobTitlesByDepartment,
    );
  }
}