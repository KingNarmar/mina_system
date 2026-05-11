import 'package:mina_system/features/workers/data/models/worker_model.dart';

String normalizeText(String value) {
  return value.trim().toLowerCase();
}

String normalizeWorkerName(String name) {
  return name.trim().toLowerCase().replaceAll(
    RegExp(r'[^\p{L}\p{N}]+', unicode: true),
    '',
  );
}

bool checkIsWorkerNameAlreadyUsed({
  required List<WorkerModel> workers,
  required String workerName,
  String? ignoredWorkerId,
}) {
  final normalizedInput = normalizeWorkerName(workerName);

  if (normalizedInput.isEmpty) {
    return false;
  }

  return workers.any((worker) {
    if (ignoredWorkerId != null && worker.id == ignoredWorkerId) {
      return false;
    }

    return normalizeWorkerName(worker.name) == normalizedInput;
  });
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

List<WorkerModel> sortWorkersAlphabetically(List<WorkerModel> workers) {
  final sortedWorkers = List<WorkerModel>.from(workers);
  sortedWorkers.sort(
    (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
  );
  return sortedWorkers;
}
