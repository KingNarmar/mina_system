class WorkerModel {
  const WorkerModel({
    required this.name,
    required this.hrCode,
    required this.department,
    required this.jobTitle,
  });

  final String name;
  final String hrCode;
  final String department;
  final String jobTitle;

  WorkerModel copyWith({
    String? name,
    String? hrCode,
    String? department,
    String? jobTitle,
  }) {
    return WorkerModel(
      name: name ?? this.name,
      hrCode: hrCode ?? this.hrCode,
      department: department ?? this.department,
      jobTitle: jobTitle ?? this.jobTitle,
    );
  }
}
