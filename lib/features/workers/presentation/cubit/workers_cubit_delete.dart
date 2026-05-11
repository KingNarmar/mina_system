part of 'workers_cubit.dart';

extension WorkersCubitDelete on WorkersCubit {
  Future<bool> deleteWorker({required WorkerModel worker}) async {
    final workerId = worker.id;

    if (workerId == null || workerId.isEmpty) {
      emitState(state.copyWith(errorMessage: 'Worker ID was not found'));
      return false;
    }

    final canContinue = await _ensureOnline();
    if (!canContinue) {
      return false;
    }

    emitState(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await _workersRepo.deleteWorker(workerId: workerId);

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
            fallback: 'Unable to delete worker. Please try again.',
          ),
        ),
      );
      return false;
    }
  }
}
