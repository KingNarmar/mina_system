import 'package:mina_system/features/workers/data/models/worker_model.dart';

String normalizeText(String value) {
  return value.trim().toLowerCase();
}

bool isSameHrCode(String firstHrCode, String secondHrCode) {
  return normalizeText(firstHrCode) == normalizeText(secondHrCode);
}

bool checkIsHrCodeAlreadyUsed({
  required List<WorkerModel> workers,
  required String hrCode,
  String? ignoredHrCode,
}) {
  final normalizedHrCode = normalizeText(hrCode);
  final normalizedIgnoredHrCode = ignoredHrCode == null
      ? null
      : normalizeText(ignoredHrCode);

  return workers.any((worker) {
    final existingHrCode = normalizeText(worker.hrCode);

    if (normalizedIgnoredHrCode != null &&
        existingHrCode == normalizedIgnoredHrCode) {
      return false;
    }

    return existingHrCode == normalizedHrCode;
  });
}

List<WorkerModel> filterWorkers({
  required List<WorkerModel> workers,
  required String query,
}) {
  final searchQuery = normalizeText(query);

  if (searchQuery.isEmpty) {
    return workers;
  }

  return workers.where((worker) {
    final name = normalizeText(worker.name);
    final hrCode = normalizeText(worker.hrCode);
    final department = normalizeText(worker.department);
    final jobTitle = normalizeText(worker.jobTitle);

    return name.contains(searchQuery) ||
        hrCode.contains(searchQuery) ||
        department.contains(searchQuery) ||
        jobTitle.contains(searchQuery);
  }).toList();
}
