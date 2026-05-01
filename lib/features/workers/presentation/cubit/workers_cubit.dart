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

  static const List<WorkerModel> _initialWorkers = [
    WorkerModel(
      name: 'Ahmed Ali',
      hrCode: 'HR-001',
      department: 'Warehouse',
      jobTitle: 'Storekeeper',
      activeCustodyCount: 6,
    ),
    WorkerModel(
      name: 'Mohamed Samir',
      hrCode: 'HR-002',
      department: 'Fabrication',
      jobTitle: 'Welder',
      activeCustodyCount: 3,
    ),
    WorkerModel(
      name: 'Khaled Hassan',
      hrCode: 'HR-003',
      department: 'Mechanical',
      jobTitle: 'Mechanic',
      activeCustodyCount: 4,
    ),
    WorkerModel(
      name: 'Sayed Mahmoud',
      hrCode: 'HR-004',
      department: 'Electrical',
      jobTitle: 'Electrician',
      activeCustodyCount: 2,
    ),
  ];
// Search worker
  void searchWorkers(String query) {
    final searchQuery = query.trim().toLowerCase();

    if (searchQuery.isEmpty) {
      emit(state.copyWith(searchQuery: '', filteredWorkers: state.workers));
      return;
    }

    final filteredWorkers = state.workers.where((worker) {
      final name = worker.name.toLowerCase();
      final hrCode = worker.hrCode.toLowerCase();
      final department = worker.department.toLowerCase();
      final jobTitle = worker.jobTitle.toLowerCase();

      return name.contains(searchQuery) ||
          hrCode.contains(searchQuery) ||
          department.contains(searchQuery) ||
          jobTitle.contains(searchQuery);
    }).toList();

    emit(state.copyWith(searchQuery: query, filteredWorkers: filteredWorkers));
  }
// Add Worker
  void addWorker(WorkerModel worker) {
    final updatedWorkers = List<WorkerModel>.from(state.workers)..add(worker);

    emit(
      state.copyWith(
        workers: updatedWorkers,
        filteredWorkers: _filterWorkers(
          workers: updatedWorkers,
          query: state.searchQuery,
        ),
      ),
    );
  }
// Delete Worker
void deleteWorker(WorkerModel worker) {
  final updatedWorkers = state.workers.where((item) {
    return item.hrCode != worker.hrCode;
  }).toList();

  emit(
    state.copyWith(
      workers: updatedWorkers,
      filteredWorkers: _filterWorkers(
        workers: updatedWorkers,
        query: state.searchQuery,
      ),
    ),
  );
}
  List<WorkerModel> _filterWorkers({
    required List<WorkerModel> workers,
    required String query,
  }) {
    final searchQuery = query.trim().toLowerCase();

    if (searchQuery.isEmpty) {
      return workers;
    }

    return workers.where((worker) {
      final name = worker.name.toLowerCase();
      final hrCode = worker.hrCode.toLowerCase();
      final department = worker.department.toLowerCase();
      final jobTitle = worker.jobTitle.toLowerCase();

      return name.contains(searchQuery) ||
          hrCode.contains(searchQuery) ||
          department.contains(searchQuery) ||
          jobTitle.contains(searchQuery);
    }).toList();
  }
}
