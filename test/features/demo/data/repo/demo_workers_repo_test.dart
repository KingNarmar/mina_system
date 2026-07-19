import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mina_system/features/demo/data/demo_limits.dart';
import 'package:mina_system/features/demo/data/repo/demo_workers_repo.dart';
import 'package:mina_system/features/demo/data/services/demo_storage_keys.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DemoWorkersRepo', () {
    test('filters by company and status and sorts by worker name', () async {
      _seedWorkers([
        _workerJson(
          id: 'worker-2',
          companyId: 'company-1',
          workerCode: 'WRK-002',
          hrCode: 'HR-002',
          name: 'Zulu Worker',
        ),
        _workerJson(
          id: 'worker-1',
          companyId: 'company-1',
          workerCode: 'WRK-001',
          hrCode: 'HR-001',
          name: 'Alpha Worker',
        ),
        _workerJson(
          id: 'worker-3',
          companyId: 'company-1',
          workerCode: 'WRK-003',
          hrCode: 'HR-003',
          name: 'Inactive Worker',
          status: 'inactive',
        ),
        _workerJson(
          id: 'worker-4',
          companyId: 'company-2',
          workerCode: 'WRK-001',
          hrCode: 'HR-001',
          name: 'Other Company Worker',
        ),
      ]);

      final repo = DemoWorkersRepo();

      final active = await repo.getWorkers(companyId: 'company-1');
      final inactive = await repo.getWorkers(
        companyId: 'company-1',
        status: 'inactive',
      );
      final all = await repo.getWorkers(
        companyId: 'company-1',
        status: null,
      );

      expect(active.map((worker) => worker.name), [
        'Alpha Worker',
        'Zulu Worker',
      ]);
      expect(inactive.single.name, 'Inactive Worker');
      expect(all, hasLength(3));
    });

    test('persists add, update, deactivate, and reactivate', () async {
      final repo = DemoWorkersRepo();
      const worker = WorkerModel(
        companyId: 'company-1',
        workerCode: 'WRK-001',
        name: 'Mina Adly',
        hrCode: 'HR-001',
        department: 'Stores',
        jobTitle: 'Storekeeper',
      );

      final added = await repo.addWorker(worker: worker);
      expect(added.id, isNotEmpty);
      expect(
        (await repo.getWorkers(companyId: 'company-1')).single.name,
        'Mina Adly',
      );

      final updated = await repo.updateWorker(
        workerId: added.id!,
        worker: added.copyWith(name: 'Updated Worker'),
      );
      expect(updated.name, 'Updated Worker');

      await repo.deleteWorker(
        companyId: 'company-1',
        workerId: added.id!,
      );
      expect(await repo.getWorkers(companyId: 'company-1'), isEmpty);
      expect(
        await repo.getWorkers(companyId: 'company-1', status: 'inactive'),
        hasLength(1),
      );

      final reactivated = await repo.reactivateWorker(
        companyId: 'company-1',
        workerId: added.id!,
      );
      expect(reactivated.status, 'active');
      expect(await repo.getWorkers(companyId: 'company-1'), hasLength(1));
    });

    test('checks duplicates and generates codes within company data', () async {
      _seedWorkers([
        _workerJson(
          id: 'worker-1',
          companyId: 'company-1',
          workerCode: 'WRK-001',
          hrCode: 'HR-001',
          name: 'Mina Adly',
        ),
        _workerJson(
          id: 'worker-9',
          companyId: 'company-1',
          workerCode: 'WRK-009',
          hrCode: 'HR-009',
          name: 'Worker Nine',
        ),
        _workerJson(
          id: 'other-worker',
          companyId: 'company-2',
          workerCode: 'WRK-100',
          hrCode: 'HR-001',
          name: 'Mina Adly',
        ),
      ]);

      final repo = DemoWorkersRepo();

      expect(
        await repo.hrCodeExists(companyId: 'company-1', hrCode: 'hr 001'),
        isTrue,
      );
      expect(
        await repo.hrCodeExists(
          companyId: 'company-1',
          hrCode: 'HR-001',
          ignoredWorkerId: 'worker-1',
        ),
        isFalse,
      );
      expect(
        await repo.workerNameExists(
          companyId: 'company-1',
          workerName: ' mina adly ',
        ),
        isTrue,
      );
      expect(
        await repo.generateNextWorkerCode(companyId: 'company-1'),
        'WRK-010',
      );
    });

    test('enforces the worker limit per company', () async {
      _seedWorkers([
        for (var index = 1; index <= DemoLimits.maxWorkers; index++)
          _workerJson(
            id: 'worker-$index',
            companyId: 'company-1',
            workerCode: 'WRK-${index.toString().padLeft(3, '0')}',
            hrCode: 'HR-$index',
            name: 'Worker $index',
          ),
      ]);

      final repo = DemoWorkersRepo();

      expect(
        repo.addWorker(
          worker: const WorkerModel(
            companyId: 'company-1',
            workerCode: 'WRK-011',
            name: 'Worker Eleven',
            hrCode: 'HR-011',
            department: 'Stores',
            jobTitle: 'Storekeeper',
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            DemoLimits.workersLimitMessage(),
          ),
        ),
      );
    });
  });
}

void _seedWorkers(List<Map<String, dynamic>> workers) {
  SharedPreferences.setMockInitialValues({
    DemoStorageKeys.workers: jsonEncode(workers),
  });
}

Map<String, dynamic> _workerJson({
  required String id,
  required String companyId,
  required String workerCode,
  required String hrCode,
  required String name,
  String status = 'active',
}) {
  return {
    'id': id,
    'company_id': companyId,
    'worker_code': workerCode,
    'hr_code': hrCode,
    'full_name': name,
    'department_id': 'department-1',
    'department_name': 'Stores',
    'job_title_id': 'job-title-1',
    'job_title_name': 'Storekeeper',
    'status': status,
    'created_at': '2026-01-01T00:00:00.000Z',
    'updated_at': '2026-01-01T00:00:00.000Z',
  };
}
