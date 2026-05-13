import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/services/network_status_service.dart';
import 'package:mina_system/core/utils/app_error_message.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/data/repo/workers_repo.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_state.dart';
import 'package:mina_system/features/workers/presentation/functions/worker_helpers.dart';

part 'workers_cubit_add.dart';
part 'workers_cubit_delete.dart';
part 'workers_cubit_update.dart';

class WorkersCubit extends Cubit<WorkersState> {
  WorkersCubit({
    WorkersRepo? workersRepo,
    NetworkStatusService? networkStatusService,
  }) : _workersRepo = workersRepo ?? WorkersRepo(),
       _networkStatusService = networkStatusService ?? NetworkStatusService(),
       super(
         const WorkersState(
           workers: _initialWorkers,
           filteredWorkers: _initialWorkers,
           searchQuery: '',
           statusFilter: 'active',
         ),
       );

  final WorkersRepo _workersRepo;
  final NetworkStatusService _networkStatusService;

  static const List<WorkerModel> _initialWorkers = [];

  Future<void> loadWorkers({
    required String companyId,
    String? statusFilter,
  }) async {
    final selectedStatus = statusFilter ?? state.statusFilter;

    emit(
      state.copyWith(
        isLoading: true,
        statusFilter: selectedStatus,
        clearErrorMessage: true,
      ),
    );

    try {
      final workers = await _workersRepo.getWorkers(
        companyId: companyId,
        status: selectedStatus,
      );

      emitUpdatedWorkers(workers, isLoading: false);
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to load workers. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> changeStatusFilter({
    required String companyId,
    required String statusFilter,
  }) async {
    if (statusFilter == state.statusFilter) {
      return;
    }

    emit(
      state.copyWith(
        statusFilter: statusFilter,
        searchQuery: '',
        filteredWorkers: const [],
      ),
    );

    await loadWorkers(companyId: companyId, statusFilter: statusFilter);
  }

  void searchWorkers(String query) {
    final filteredWorkers = filterWorkers(workers: state.workers, query: query);

    emit(state.copyWith(searchQuery: query, filteredWorkers: filteredWorkers));
  }

  bool isHrCodeAlreadyUsed(String hrCode, {String? ignoredHrCode}) {
    return checkIsHrCodeAlreadyUsed(
      workers: state.workers,
      hrCode: hrCode,
      ignoredHrCode: ignoredHrCode,
    );
  }

  bool isWorkerNameAlreadyUsed(String name, {String? ignoredWorkerId}) {
    return checkIsWorkerNameAlreadyUsed(
      workers: state.workers,
      workerName: name,
      ignoredWorkerId: ignoredWorkerId,
    );
  }

  void clearErrorMessage() {
    if (state.errorMessage == null) {
      return;
    }

    emit(state.copyWith(clearErrorMessage: true));
  }

  void emitState(WorkersState state) => emit(state);

  Future<bool> _ensureOnline() async {
    try {
      await _networkStatusService.ensureOnline();
      return true;
    } on NetworkUnavailableException catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.message));
      return false;
    }
  }

  void emitUpdatedWorkers(
    List<WorkerModel> workers, {
    bool? isLoading,
    bool? isSubmitting,
  }) {
    final sortedWorkers = sortWorkersAlphabetically(workers);
    emit(
      state.copyWith(
        workers: sortedWorkers,
        filteredWorkers: filterWorkers(
          workers: sortedWorkers,
          query: state.searchQuery,
        ),
        isLoading: isLoading,
        isSubmitting: isSubmitting,
        clearErrorMessage: true,
      ),
    );
  }
}
