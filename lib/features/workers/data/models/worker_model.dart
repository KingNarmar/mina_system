class WorkerModel {
  const WorkerModel({
    required this.name,
    required this.hrCode,
    required this.department,
    required this.jobTitle,
    required this.activeCustodyCount,
  });

  final String name;
  final String hrCode;
  final String department;
  final String jobTitle;
  final int activeCustodyCount;
}
