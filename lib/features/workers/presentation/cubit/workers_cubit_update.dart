part of 'workers_cubit.dart';

extension WorkersCubitUpdate on WorkersCubit {
  Future<bool> updateWorker({
    required String companyId,
    required WorkerModel updatedWorker,
  }) async {
    final workerId = updatedWorker.id;
    final cleanName = updatedWorker.name.trim();
    final cleanHrCode = updatedWorker.hrCode.trim();

    if (workerId == null || workerId.isEmpty) {
      emitState(state.copyWith(errorMessage: 'Worker ID was not found'));
      return false;
    }

    if (cleanName.isEmpty || cleanHrCode.isEmpty) {
      return false;
    }

    if (updatedWorker.departmentId == null ||
        updatedWorker.jobTitleId == null) {
      emitState(
        state.copyWith(errorMessage: 'Department and job title are required'),
      );
      return false;
    }

    final canContinue = await _ensureOnline();
    if (!canContinue) {
      return false;
    }

    emitState(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final isDuplicatedHrCode = await _workersRepo.hrCodeExists(
        companyId: companyId,
        hrCode: cleanHrCode,
        ignoredWorkerId: workerId,
      );

      if (isDuplicatedHrCode) {
        emitState(
          state.copyWith(
            isSubmitting: false,
            errorMessage: 'HR Code already exists',
          ),
        );
        return false;
      }

      final isDuplicatedName = await _workersRepo.workerNameExists(
        companyId: companyId,
        workerName: cleanName,
        ignoredWorkerId: workerId,
      );

      if (isDuplicatedName) {
        emitState(
          state.copyWith(
            isSubmitting: false,
            errorMessage: 'Worker name already exists',
          ),
        );
        return false;
      }

      final workerToUpdate = updatedWorker.copyWith(
        companyId: companyId,
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
      emitState(
        state.copyWith(
          isSubmitting: false,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to update worker. Please try again.',
          ),
        ),
      );
      return false;
    }
  }
}
