import 'package:mina_system/features/workers/data/models/worker_model.dart';

class WorkersState {
  const WorkersState({
    required this.workers,
    required this.filteredWorkers,
    required this.searchQuery,
  });

  final List<WorkerModel> workers;
  final List<WorkerModel> filteredWorkers;
  final String searchQuery;

  WorkersState copyWith({
    List<WorkerModel>? workers,
    List<WorkerModel>? filteredWorkers,
    String? searchQuery,
  }) {
    return WorkersState(
      workers: workers ?? this.workers,
      filteredWorkers: filteredWorkers ?? this.filteredWorkers,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
