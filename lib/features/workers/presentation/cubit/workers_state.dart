import 'package:mina_system/features/workers/data/models/worker_model.dart';

class WorkersSubmissionKeys {
  const WorkersSubmissionKeys._();

  static const String add = 'workers:add';

  static String update(String workerId) {
    return 'workers:update:$workerId';
  }

  static String delete(String workerId) {
    return 'workers:delete:$workerId';
  }

  static String reactivate(String workerId) {
    return 'workers:reactivate:$workerId';
  }
}

class WorkersState {
  const WorkersState({
    required this.workers,
    required this.filteredWorkers,
    required this.searchQuery,
    this.statusFilter = 'active',
    this.isLoading = false,
    this.isSubmitting = false,
    this.submittingActionKey,
    this.errorMessage,
  });

  final List<WorkerModel> workers;
  final List<WorkerModel> filteredWorkers;
  final String searchQuery;
  final String statusFilter;
  final bool isLoading;
  final bool isSubmitting;
  final String? submittingActionKey;
  final String? errorMessage;

  bool isActionSubmitting(String actionKey) {
    return isSubmitting && submittingActionKey == actionKey;
  }

  WorkersState copyWith({
    List<WorkerModel>? workers,
    List<WorkerModel>? filteredWorkers,
    String? searchQuery,
    String? statusFilter,
    bool? isLoading,
    bool? isSubmitting,
    String? submittingActionKey,
    String? errorMessage,
    bool clearSubmittingActionKey = false,
    bool clearErrorMessage = false,
  }) {
    final nextIsSubmitting = isSubmitting ?? this.isSubmitting;

    return WorkersState(
      workers: workers ?? this.workers,
      filteredWorkers: filteredWorkers ?? this.filteredWorkers,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: nextIsSubmitting,
      submittingActionKey: clearSubmittingActionKey || !nextIsSubmitting
          ? null
          : submittingActionKey ?? this.submittingActionKey,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
