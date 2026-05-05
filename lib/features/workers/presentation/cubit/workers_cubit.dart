import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/data/repo/workers_repo.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_state.dart';
import 'package:mina_system/features/workers/presentation/functions/worker_helpers.dart';

class WorkersCubit extends Cubit<WorkersState> {
  WorkersCubit({WorkersRepo? workersRepo})
    : _workersRepo = workersRepo ?? WorkersRepo(),
      super(
        const WorkersState(
          workers: _initialWorkers,
          filteredWorkers: _initialWorkers,
          searchQuery: '',
        ),
      );

  final WorkersRepo _workersRepo;

  static const List<WorkerModel> _initialWorkers = [];

  Future<void> loadWorkers({required String companyId}) async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    try {
      final workers = await _workersRepo.getWorkers(companyId: companyId);

      emitUpdatedWorkers(workers, isLoading: false);
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  void searchWorkers(String query) {
    final filteredWorkers = filterWorkers(workers: state.workers, query: query);

    emit(state.copyWith(searchQuery: query, filteredWorkers: filteredWorkers));
  }

  Future<bool> addWorker({
    required String companyId,
    required String createdByProfileId,
    required WorkerModel worker,
  }) async {
    final cleanName = worker.name.trim();
    final cleanHrCode = worker.hrCode.trim();

    if (cleanName.isEmpty || cleanHrCode.isEmpty) {
      return false;
    }

    if (worker.departmentId == null || worker.jobTitleId == null) {
      emit(
        state.copyWith(errorMessage: 'Department and job title are required'),
      );
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final isDuplicatedHrCode = await _workersRepo.hrCodeExists(
        companyId: companyId,
        hrCode: cleanHrCode,
      );

      if (isDuplicatedHrCode) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: 'HR Code already exists',
          ),
        );
        return false;
      }

      final workerCode = await _workersRepo.generateNextWorkerCode(
        companyId: companyId,
      );

      final workerToInsert = worker.copyWith(
        companyId: companyId,
        workerCode: workerCode,
        name: cleanName,
        hrCode: cleanHrCode,
        createdByProfileId: createdByProfileId,
        status: 'active',
      );

      final addedWorker = await _workersRepo.addWorker(worker: workerToInsert);

      emitUpdatedWorkers([...state.workers, addedWorker], isSubmitting: false);

      return true;
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
      return false;
    }
  }

  Future<bool> updateWorker({
    required String companyId,
    required WorkerModel updatedWorker,
  }) async {
    final workerId = updatedWorker.id;
    final cleanName = updatedWorker.name.trim();
    final cleanHrCode = updatedWorker.hrCode.trim();

    if (workerId == null || workerId.isEmpty) {
      emit(state.copyWith(errorMessage: 'Worker ID was not found'));
      return false;
    }

    if (cleanName.isEmpty || cleanHrCode.isEmpty) {
      return false;
    }

    if (updatedWorker.departmentId == null ||
        updatedWorker.jobTitleId == null) {
      emit(
        state.copyWith(errorMessage: 'Department and job title are required'),
      );
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final isDuplicatedHrCode = await _workersRepo.hrCodeExists(
        companyId: companyId,
        hrCode: cleanHrCode,
        ignoredWorkerId: workerId,
      );

      if (isDuplicatedHrCode) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: 'HR Code already exists',
          ),
        );
        return false;
      }

      final workerToUpdate = updatedWorker.copyWith(
        name: cleanName,
        hrCode: cleanHrCode,
      );

      final savedWorker = await _workersRepo.updateWorker(
        workerId: workerId,
        worker: workerToUpdate,
      );

      final updatedWorkers = state.workers.map((worker) {
        if (worker.id == workerId) {
          return savedWorker;
        }

        return worker;
      }).toList();

      emitUpdatedWorkers(updatedWorkers, isSubmitting: false);

      return true;
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
      return false;
    }
  }

  Future<bool> deleteWorker({required WorkerModel worker}) async {
    final workerId = worker.id;

    if (workerId == null || workerId.isEmpty) {
      emit(state.copyWith(errorMessage: 'Worker ID was not found'));
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await _workersRepo.deleteWorker(workerId: workerId);

      final updatedWorkers = state.workers.where((item) {
        return item.id != workerId;
      }).toList();

      emitUpdatedWorkers(updatedWorkers, isSubmitting: false);

      return true;
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
      return false;
    }
  }

  bool isHrCodeAlreadyUsed(String hrCode, {String? ignoredHrCode}) {
    return checkIsHrCodeAlreadyUsed(
      workers: state.workers,
      hrCode: hrCode,
      ignoredHrCode: ignoredHrCode,
    );
  }

  void emitUpdatedWorkers(
    List<WorkerModel> workers, {
    bool? isLoading,
    bool? isSubmitting,
  }) {
    emit(
      state.copyWith(
        workers: workers,
        filteredWorkers: filterWorkers(
          workers: workers,
          query: state.searchQuery,
        ),
        isLoading: isLoading,
        isSubmitting: isSubmitting,
        clearErrorMessage: true,
      ),
    );
  }
}
