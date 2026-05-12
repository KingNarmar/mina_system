part of 'workers_cubit.dart';

extension WorkersCubitDelete on WorkersCubit {
  Future<bool> deleteWorker({required WorkerModel worker}) async {
    final workerId = worker.id;
    final companyId = worker.companyId;

    if (workerId == null || workerId.isEmpty) {
      emitState(state.copyWith(errorMessage: 'Worker ID was not found'));
      return false;
    }

    if (companyId == null || companyId.isEmpty) {
      emitState(state.copyWith(errorMessage: 'Company ID was not found'));
      return false;
    }

    final canContinue = await _ensureOnline();
    if (!canContinue) {
      return false;
    }

    emitState(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await _workersRepo.deleteWorker(companyId: companyId, workerId: workerId);

      final updatedWorkers = state.workers.where((item) {
        return item.id != workerId;
      }).toList();

      emitUpdatedWorkers(updatedWorkers, isSubmitting: false);

      return true;
    } catch (error) {
      emitState(
        state.copyWith(
          isSubmitting: false,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to deactivate worker. Please try again.',
          ),
        ),
      );
      return false;
    }
  }

  Future<bool> reactivateWorker({required WorkerModel worker}) async {
    final workerId = worker.id;
    final companyId = worker.companyId;

    if (workerId == null || workerId.isEmpty) {
      emitState(state.copyWith(errorMessage: 'Worker ID was not found'));
      return false;
    }

    if (companyId == null || companyId.isEmpty) {
      emitState(state.copyWith(errorMessage: 'Company ID was not found'));
      return false;
    }

    final canContinue = await _ensureOnline();
    if (!canContinue) {
      return false;
    }

    emitState(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await _workersRepo.reactivateWorker(
        companyId: companyId,
        workerId: workerId,
      );

      final updatedWorkers = state.workers.where((item) {
        return item.id != workerId;
      }).toList();

      emitUpdatedWorkers(updatedWorkers, isSubmitting: false);

      return true;
    } catch (error) {
      emitState(
        state.copyWith(
          isSubmitting: false,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to reactivate worker. Please try again.',
          ),
        ),
      );
      return false;
    }
  }
}
