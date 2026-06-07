import 'package:mina_system/features/demo/data/services/demo_local_storage_service.dart';
import 'package:mina_system/features/demo/data/services/demo_seed_service.dart';
import 'package:mina_system/features/demo/data/services/demo_storage_keys.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:mina_system/features/workers/data/repo/workers_repo.dart';

class DemoWorkersRepo extends WorkersRepo {
  DemoWorkersRepo({
    DemoLocalStorageService storage = const DemoLocalStorageService(),
  }) : _storage = storage;

  final DemoLocalStorageService _storage;

  @override
  Future<List<WorkerModel>> getWorkers({
    required String companyId,
    String? status = 'active',
  }) async {
    final workersData = await _storage.readJsonList(DemoStorageKeys.workers);
    final cleanStatus = status?.trim().toLowerCase();

    final workers = workersData
        .where((item) {
          final itemCompanyId = item['company_id'] as String?;
          final itemStatus = item['status'] as String? ?? 'active';

          if (itemCompanyId != companyId) {
            return false;
          }

          if (cleanStatus == null || cleanStatus.isEmpty) {
            return true;
          }

          return itemStatus.trim().toLowerCase() == cleanStatus;
        })
        .map(WorkerModel.fromJson)
        .toList();

    workers.sort((first, second) {
      return first.name.toLowerCase().compareTo(second.name.toLowerCase());
    });

    return workers;
  }

  @override
  Future<WorkerModel> addWorker({required WorkerModel worker}) async {
    final workersData = await _storage.readJsonList(DemoStorageKeys.workers);

    final now = DateTime.now().toIso8601String();
    final workerId = worker.id?.trim().isNotEmpty == true
        ? worker.id!.trim()
        : 'demo-worker-${DateTime.now().microsecondsSinceEpoch}';

    final workerToSave = worker.copyWith(
      id: workerId,
      companyId: worker.companyId ?? DemoSeedService.demoCompanyId,
      status: 'active',
      createdByProfileId: DemoSeedService.demoProfileId,
      updatedByProfileId: DemoSeedService.demoProfileId,
      createdByProfileName: 'Demo User',
      createdByProfileEmail: 'demo@mina-system.local',
      updatedByProfileName: 'Demo User',
      updatedByProfileEmail: 'demo@mina-system.local',
      createdAt: DateTime.parse(now),
      updatedAt: DateTime.parse(now),
    );

    final savedJson = _workerToJson(
      workerToSave,
      createdAt: now,
      updatedAt: now,
    );

    await _storage.writeJsonList(
      key: DemoStorageKeys.workers,
      value: [...workersData, savedJson],
    );

    return WorkerModel.fromJson(savedJson);
  }

  @override
  Future<WorkerModel> updateWorker({
    required String workerId,
    required WorkerModel worker,
  }) async {
    final workersData = await _storage.readJsonList(DemoStorageKeys.workers);
    final now = DateTime.now().toIso8601String();

    Map<String, dynamic>? savedJson;

    final updatedWorkers = workersData.map((item) {
      if (item['id'] != workerId) {
        return item;
      }

      final createdAt = item['created_at'] as String? ?? now;
      savedJson = _workerToJson(
        worker.copyWith(
          id: workerId,
          companyId: worker.companyId ?? DemoSeedService.demoCompanyId,
          updatedByProfileId: DemoSeedService.demoProfileId,
          updatedByProfileName: 'Demo User',
          updatedByProfileEmail: 'demo@mina-system.local',
          updatedAt: DateTime.parse(now),
        ),
        createdAt: createdAt,
        updatedAt: now,
      );

      return savedJson!;
    }).toList();

    if (savedJson == null) {
      throw StateError('Demo worker was not found.');
    }

    await _storage.writeJsonList(
      key: DemoStorageKeys.workers,
      value: updatedWorkers,
    );

    return WorkerModel.fromJson(savedJson!);
  }

  @override
  Future<void> deleteWorker({
    required String companyId,
    required String workerId,
  }) async {
    await _updateWorkerStatus(
      companyId: companyId,
      workerId: workerId,
      status: 'inactive',
    );
  }

  @override
  Future<WorkerModel> reactivateWorker({
    required String companyId,
    required String workerId,
  }) async {
    return _updateWorkerStatus(
      companyId: companyId,
      workerId: workerId,
      status: 'active',
    );
  }

  @override
  Future<bool> hrCodeExists({
    required String companyId,
    required String hrCode,
    String? ignoredWorkerId,
  }) async {
    final workers = await getWorkers(companyId: companyId, status: null);
    final cleanHrCode = _normalizeValue(hrCode);

    return workers.any((worker) {
      if (ignoredWorkerId != null && worker.id == ignoredWorkerId) {
        return false;
      }

      return _normalizeValue(worker.hrCode) == cleanHrCode;
    });
  }

  @override
  Future<bool> workerNameExists({
    required String companyId,
    required String workerName,
    String? ignoredWorkerId,
  }) async {
    final workers = await getWorkers(companyId: companyId, status: 'active');
    final cleanName = _normalizeName(workerName);

    return workers.any((worker) {
      if (ignoredWorkerId != null && worker.id == ignoredWorkerId) {
        return false;
      }

      return _normalizeName(worker.name) == cleanName;
    });
  }

  @override
  Future<bool> workerCodeExists({
    required String companyId,
    required String workerCode,
    String? ignoredWorkerId,
  }) async {
    final workers = await getWorkers(companyId: companyId, status: null);
    final cleanWorkerCode = _normalizeValue(workerCode);

    return workers.any((worker) {
      if (ignoredWorkerId != null && worker.id == ignoredWorkerId) {
        return false;
      }

      return _normalizeValue(worker.workerCode ?? '') == cleanWorkerCode;
    });
  }

  @override
  Future<String> generateNextWorkerCode({required String companyId}) async {
    final workers = await getWorkers(companyId: companyId, status: null);

    var maxNumber = 0;

    for (final worker in workers) {
      final number = _extractEndingNumber(worker.workerCode);

      if (number > maxNumber) {
        maxNumber = number;
      }
    }

    final nextNumber = maxNumber + 1;

    return 'WRK-${nextNumber.toString().padLeft(3, '0')}';
  }

  Future<WorkerModel> _updateWorkerStatus({
    required String companyId,
    required String workerId,
    required String status,
  }) async {
    final workersData = await _storage.readJsonList(DemoStorageKeys.workers);
    final now = DateTime.now().toIso8601String();

    Map<String, dynamic>? savedJson;

    final updatedWorkers = workersData.map((item) {
      if (item['id'] != workerId || item['company_id'] != companyId) {
        return item;
      }

      savedJson = {
        ...item,
        'status': status,
        'updated_by_profile_id': DemoSeedService.demoProfileId,
        'updated_by_profile_name': 'Demo User',
        'updated_by_profile_email': 'demo@mina-system.local',
        'updated_at': now,
      };

      return savedJson!;
    }).toList();

    if (savedJson == null) {
      throw StateError('Demo worker was not found.');
    }

    await _storage.writeJsonList(
      key: DemoStorageKeys.workers,
      value: updatedWorkers,
    );

    return WorkerModel.fromJson(savedJson!);
  }

  Map<String, dynamic> _workerToJson(
    WorkerModel worker, {
    required String createdAt,
    required String updatedAt,
  }) {
    return {
      'id': worker.id,
      'company_id': worker.companyId ?? DemoSeedService.demoCompanyId,
      'worker_code': worker.workerCode,
      'hr_code': worker.hrCode,
      'full_name': worker.name,
      'department_id': worker.departmentId,
      'department_name': worker.department,
      'job_title_id': worker.jobTitleId,
      'job_title_name': worker.jobTitle,
      'phone': worker.phone,
      'email': worker.email,
      'status': worker.status,
      'notes': worker.notes,
      'created_by_profile_id':
          worker.createdByProfileId ?? DemoSeedService.demoProfileId,
      'created_by_profile_name': worker.createdByProfileName ?? 'Demo User',
      'created_by_profile_email':
          worker.createdByProfileEmail ?? 'demo@mina-system.local',
      'updated_by_profile_id':
          worker.updatedByProfileId ?? DemoSeedService.demoProfileId,
      'updated_by_profile_name': worker.updatedByProfileName ?? 'Demo User',
      'updated_by_profile_email':
          worker.updatedByProfileEmail ?? 'demo@mina-system.local',
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String _normalizeValue(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  String _normalizeName(String value) {
    return value.trim().toLowerCase().replaceAll(
      RegExp(r'[^\p{L}\p{N}]+', unicode: true),
      '',
    );
  }

  int _extractEndingNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 0;
    }

    final match = RegExp(r'(\d+)$').firstMatch(value.trim());

    if (match == null) {
      return 0;
    }

    return int.tryParse(match.group(1) ?? '') ?? 0;
  }
}
