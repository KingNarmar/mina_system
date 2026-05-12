import 'package:mina_system/features/workers/data/models/worker_model.dart';

class WorkersState {
  const WorkersState({
    required this.workers,
    required this.filteredWorkers,
    required this.searchQuery,
    this.statusFilter = 'active',
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final List<WorkerModel> workers;
  final List<WorkerModel> filteredWorkers;
  final String searchQuery;
  final String statusFilter;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  WorkersState copyWith({
    List<WorkerModel>? workers,
    List<WorkerModel>? filteredWorkers,
    String? searchQuery,
    String? statusFilter,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return WorkersState(
      workers: workers ?? this.workers,
      filteredWorkers: filteredWorkers ?? this.filteredWorkers,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
