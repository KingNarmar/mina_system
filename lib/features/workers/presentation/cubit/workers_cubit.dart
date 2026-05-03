import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_state.dart';
import 'package:mina_system/features/workers/presentation/functions/worker_helpers.dart';

class WorkersCubit extends Cubit<WorkersState> {
  WorkersCubit()
    : super(
        const WorkersState(
          workers: _initialWorkers,
          filteredWorkers: _initialWorkers,
          searchQuery: '',
        ),
      );

  static const List<WorkerModel> _initialWorkers = [];

  void searchWorkers(String query) {
    final filteredWorkers = filterWorkers(workers: state.workers, query: query);

    emit(state.copyWith(searchQuery: query, filteredWorkers: filteredWorkers));
  }

  void addWorker(WorkerModel worker) {
    if (isHrCodeAlreadyUsed(worker.hrCode)) {
      return;
    }

    final updatedWorkers = List<WorkerModel>.from(state.workers)..add(worker);

    emitUpdatedWorkers(updatedWorkers);
  }

  void updateWorker({
    required String currentHrCode,
    required WorkerModel updatedWorker,
  }) {
    if (isHrCodeAlreadyUsed(
      updatedWorker.hrCode,
      ignoredHrCode: currentHrCode,
    )) {
      return;
    }

    final updatedWorkers = state.workers.map((worker) {
      if (isSameHrCode(worker.hrCode, currentHrCode)) {
        return updatedWorker;
      }

      return worker;
    }).toList();

    emitUpdatedWorkers(updatedWorkers);
  }

  void deleteWorker(WorkerModel worker) {
    final updatedWorkers = state.workers.where((item) {
      return !isSameHrCode(item.hrCode, worker.hrCode);
    }).toList();

    emitUpdatedWorkers(updatedWorkers);
  }

  bool isHrCodeAlreadyUsed(String hrCode, {String? ignoredHrCode}) {
    return checkIsHrCodeAlreadyUsed(
      workers: state.workers,
      hrCode: hrCode,
      ignoredHrCode: ignoredHrCode,
    );
  }

  void emitUpdatedWorkers(List<WorkerModel> workers) {
    emit(
      state.copyWith(
        workers: workers,
        filteredWorkers: filterWorkers(
          workers: workers,
          query: state.searchQuery,
        ),
      ),
    );
  }
}
