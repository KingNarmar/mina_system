part of 'workers_cubit.dart';

extension WorkersCubitAdd on WorkersCubit {
  Future<bool> addWorker({
    required String companyId,
    required WorkerModel worker,
  }) async {
    final cleanName = worker.name.trim();
    final cleanHrCode = worker.hrCode.trim();

    if (cleanName.isEmpty || cleanHrCode.isEmpty) {
      return false;
    }

    if (worker.departmentId == null || worker.jobTitleId == null) {
      emitState(
        state.copyWith(errorMessage: 'Department and job title are required'),
      );
      return false;
    }

    final canContinue = await _ensureOnline();
    if (!canContinue) {
      return false;
    }

    emitState(
      state.copyWith(
        isSubmitting: true,
        submittingActionKey: WorkersSubmissionKeys.add,
        clearErrorMessage: true,
      ),
    );

    try {
      final isDuplicatedHrCode = await _workersRepo.hrCodeExists(
        companyId: companyId,
        hrCode: cleanHrCode,
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

      final workerCode = await _workersRepo.generateNextWorkerCode(
        companyId: companyId,
      );

      final workerToInsert = worker.copyWith(
        companyId: companyId,
        workerCode: workerCode,
        name: cleanName,
        hrCode: cleanHrCode,
        status: 'active',
      );

      final addedWorker = await _workersRepo.addWorker(worker: workerToInsert);

      emitUpdatedWorkers([...state.workers, addedWorker], isSubmitting: false);

      return true;
    } catch (error) {
      emitState(
        state.copyWith(
          isSubmitting: false,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to add worker. Please try again.',
          ),
        ),
      );
      return false;
    }
  }
}
