import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_state.dart';

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
    final filteredWorkers = _filterWorkers(
      workers: state.workers,
      query: query,
    );

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
      if (_isSameHrCode(worker.hrCode, currentHrCode)) {
        return updatedWorker.copyWith(
          activeCustodyCount: worker.activeCustodyCount,
        );
      }

      return worker;
    }).toList();

    emitUpdatedWorkers(updatedWorkers);
  }

  void deleteWorker(WorkerModel worker) {
    final updatedWorkers = state.workers.where((item) {
      return !_isSameHrCode(item.hrCode, worker.hrCode);
    }).toList();

    emitUpdatedWorkers(updatedWorkers);
  }

  bool isHrCodeAlreadyUsed(String hrCode, {String? ignoredHrCode}) {
    final normalizedHrCode = _normalizeText(hrCode);
    final normalizedIgnoredHrCode = ignoredHrCode == null
        ? null
        : _normalizeText(ignoredHrCode);

    return state.workers.any((worker) {
      final existingHrCode = _normalizeText(worker.hrCode);

      if (normalizedIgnoredHrCode != null &&
          existingHrCode == normalizedIgnoredHrCode) {
        return false;
      }

      return existingHrCode == normalizedHrCode;
    });
  }

  void updateWorkerCustodyCount({required String hrCode, required int change}) {
    final updatedWorkers = state.workers.map((worker) {
      if (_isSameHrCode(worker.hrCode, hrCode)) {
        final updatedCount = worker.activeCustodyCount + change;

        return worker.copyWith(
          activeCustodyCount: updatedCount < 0 ? 0 : updatedCount,
        );
      }

      return worker;
    }).toList();

    emitUpdatedWorkers(updatedWorkers);
  }

  void emitUpdatedWorkers(List<WorkerModel> workers) {
    emit(
      state.copyWith(
        workers: workers,
        filteredWorkers: _filterWorkers(
          workers: workers,
          query: state.searchQuery,
        ),
      ),
    );
  }

  List<WorkerModel> _filterWorkers({
    required List<WorkerModel> workers,
    required String query,
  }) {
    final searchQuery = _normalizeText(query);

    if (searchQuery.isEmpty) {
      return workers;
    }

    return workers.where((worker) {
      final name = _normalizeText(worker.name);
      final hrCode = _normalizeText(worker.hrCode);
      final department = _normalizeText(worker.department);
      final jobTitle = _normalizeText(worker.jobTitle);

      return name.contains(searchQuery) ||
          hrCode.contains(searchQuery) ||
          department.contains(searchQuery) ||
          jobTitle.contains(searchQuery);
    }).toList();
  }

  bool _isSameHrCode(String firstHrCode, String secondHrCode) {
    return _normalizeText(firstHrCode) == _normalizeText(secondHrCode);
  }

  String _normalizeText(String value) {
    return value.trim().toLowerCase();
  }
}
