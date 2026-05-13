import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/worker_model.dart';

class WorkersRepo {
  WorkersRepo({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  static const String _workerSelectColumns = '''
    id,
    company_id,
    worker_code,
    hr_code,
    full_name,
    department_id,
    job_title_id,
    phone,
    email,
    status,
    notes,
    created_by_profile_id,
    updated_by_profile_id,
    created_at,
    updated_at,
    departments(name),
    job_titles(name),
    created_by_profile:profiles!workers_created_by_profile_id_fkey(
      full_name,
      email
    ),
    updated_by_profile:profiles!workers_updated_by_profile_id_fkey(
      full_name,
      email
    )
  ''';

  Future<List<WorkerModel>> getWorkers({
    required String companyId,
    String? status = 'active',
  }) async {
    final cleanStatus = status?.trim().toLowerCase();

    final query = _supabase
        .from('workers')
        .select(_workerSelectColumns)
        .eq('company_id', companyId);

    final data = cleanStatus == null || cleanStatus.isEmpty
        ? await query.order('full_name')
        : await query.eq('status', cleanStatus).order('full_name');

    return data.map((item) {
      return WorkerModel.fromJson(item);
    }).toList();
  }

  Future<WorkerModel> addWorker({required WorkerModel worker}) async {
    final companyId = worker.companyId;
    final workerCode = worker.workerCode;

    if (companyId == null || companyId.trim().isEmpty) {
      throw StateError('Company ID was not found.');
    }

    if (workerCode == null || workerCode.trim().isEmpty) {
      throw StateError('Worker code was not found.');
    }

    if (worker.departmentId == null || worker.departmentId!.trim().isEmpty) {
      throw StateError('Department was not found.');
    }

    if (worker.jobTitleId == null || worker.jobTitleId!.trim().isEmpty) {
      throw StateError('Job title was not found.');
    }

    final rpcResult = await _supabase.rpc(
      'create_worker',
      params: {
        'p_company_id': companyId,
        'p_worker_code': workerCode,
        'p_hr_code': worker.hrCode.trim(),
        'p_full_name': worker.name.trim(),
        'p_department_id': worker.departmentId,
        'p_job_title_id': worker.jobTitleId,
        'p_phone': _emptyToNull(worker.phone),
        'p_email': _emptyToNull(worker.email),
        'p_notes': _emptyToNull(worker.notes),
      },
    );

    final workerId = _readRpcUuidResult(rpcResult, 'create_worker');

    final data = await _supabase
        .from('workers')
        .select(_workerSelectColumns)
        .eq('id', workerId)
        .eq('company_id', companyId)
        .single();

    return WorkerModel.fromJson(data);
  }

  Future<WorkerModel> updateWorker({
    required String workerId,
    required WorkerModel worker,
  }) async {
    final companyId = worker.companyId;
    final workerCode = worker.workerCode;

    if (companyId == null || companyId.trim().isEmpty) {
      throw StateError('Company ID was not found.');
    }

    if (workerCode == null || workerCode.trim().isEmpty) {
      throw StateError('Worker code was not found.');
    }

    if (worker.departmentId == null || worker.departmentId!.trim().isEmpty) {
      throw StateError('Department was not found.');
    }

    if (worker.jobTitleId == null || worker.jobTitleId!.trim().isEmpty) {
      throw StateError('Job title was not found.');
    }

    final rpcResult = await _supabase.rpc(
      'update_worker',
      params: {
        'p_company_id': companyId,
        'p_worker_id': workerId,
        'p_worker_code': workerCode,
        'p_hr_code': worker.hrCode.trim(),
        'p_full_name': worker.name.trim(),
        'p_department_id': worker.departmentId,
        'p_job_title_id': worker.jobTitleId,
        'p_phone': _emptyToNull(worker.phone),
        'p_email': _emptyToNull(worker.email),
        'p_status': worker.status,
        'p_notes': _emptyToNull(worker.notes),
      },
    );

    final savedWorkerId = _readRpcUuidResult(rpcResult, 'update_worker');

    final data = await _supabase
        .from('workers')
        .select(_workerSelectColumns)
        .eq('id', savedWorkerId)
        .eq('company_id', companyId)
        .single();

    return WorkerModel.fromJson(data);
  }

  Future<void> deleteWorker({
    required String companyId,
    required String workerId,
  }) async {
    if (companyId.trim().isEmpty) {
      throw StateError('Company ID was not found.');
    }

    if (workerId.trim().isEmpty) {
      throw StateError('Worker ID was not found.');
    }

    await _supabase.rpc(
      'deactivate_worker',
      params: {'p_company_id': companyId, 'p_worker_id': workerId},
    );
  }

  Future<WorkerModel> reactivateWorker({
    required String companyId,
    required String workerId,
  }) async {
    if (companyId.trim().isEmpty) {
      throw StateError('Company ID was not found.');
    }

    if (workerId.trim().isEmpty) {
      throw StateError('Worker ID was not found.');
    }

    final rpcResult = await _supabase.rpc(
      'reactivate_worker',
      params: {'p_company_id': companyId, 'p_worker_id': workerId},
    );

    final savedWorkerId = _readRpcUuidResult(rpcResult, 'reactivate_worker');

    final data = await _supabase
        .from('workers')
        .select(_workerSelectColumns)
        .eq('id', savedWorkerId)
        .eq('company_id', companyId)
        .single();

    return WorkerModel.fromJson(data);
  }

  Future<bool> hrCodeExists({
    required String companyId,
    required String hrCode,
    String? ignoredWorkerId,
  }) async {
    final cleanHrCode = hrCode.trim();

    if (cleanHrCode.isEmpty) {
      return false;
    }

    final data = await _supabase
        .from('workers')
        .select('id, hr_code')
        .eq('company_id', companyId);

    return data.any((item) {
      final workerId = item['id'] as String?;
      final existingHrCode = item['hr_code'] as String?;

      if (ignoredWorkerId != null && workerId == ignoredWorkerId) {
        return false;
      }

      return _isSameWorkerCode(existingHrCode, cleanHrCode);
    });
  }

  Future<bool> workerNameExists({
    required String companyId,
    required String workerName,
    String? ignoredWorkerId,
  }) async {
    final cleanName = workerName.trim();

    if (cleanName.isEmpty) {
      return false;
    }

    final normalizedInput = _normalizeWorkerName(cleanName);

    if (normalizedInput.isEmpty) {
      return false;
    }

    final data = await _supabase
        .from('workers')
        .select('id, full_name')
        .eq('company_id', companyId)
        .eq('status', 'active');

    return data.any((item) {
      final workerId = item['id'] as String?;
      final existingName = item['full_name'] as String? ?? '';

      if (ignoredWorkerId != null && workerId == ignoredWorkerId) {
        return false;
      }

      return _normalizeWorkerName(existingName) == normalizedInput;
    });
  }

  Future<bool> workerCodeExists({
    required String companyId,
    required String workerCode,
    String? ignoredWorkerId,
  }) async {
    final cleanWorkerCode = workerCode.trim();

    if (cleanWorkerCode.isEmpty) {
      return false;
    }

    final data = await _supabase
        .from('workers')
        .select('id, worker_code')
        .eq('company_id', companyId);

    return data.any((item) {
      final workerId = item['id'] as String?;
      final existingWorkerCode = item['worker_code'] as String?;

      if (ignoredWorkerId != null && workerId == ignoredWorkerId) {
        return false;
      }

      return _isSameWorkerCode(existingWorkerCode, cleanWorkerCode);
    });
  }

  Future<String> generateNextWorkerCode({required String companyId}) async {
    final data = await _supabase
        .from('workers')
        .select('worker_code')
        .eq('company_id', companyId);

    var maxNumber = 0;

    for (final item in data) {
      final workerCode = item['worker_code'] as String?;
      final number = _extractEndingNumber(workerCode);

      if (number > maxNumber) {
        maxNumber = number;
      }
    }

    final nextNumber = maxNumber + 1;
    return 'WRK-${nextNumber.toString().padLeft(3, '0')}';
  }

  bool _isSameWorkerCode(String? firstValue, String secondValue) {
    if (firstValue == null) {
      return false;
    }

    return _normalizeWorkerCode(firstValue) ==
        _normalizeWorkerCode(secondValue);
  }

  String _normalizeWorkerCode(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  String _normalizeWorkerName(String value) {
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

  String _readRpcUuidResult(dynamic rpcResult, String functionName) {
    if (rpcResult is String && rpcResult.trim().isNotEmpty) {
      return rpcResult.trim();
    }

    if (rpcResult is Map<String, dynamic>) {
      final value = rpcResult[functionName] as String?;

      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    if (rpcResult is List && rpcResult.isNotEmpty) {
      final firstItem = rpcResult.first;

      if (firstItem is String && firstItem.trim().isNotEmpty) {
        return firstItem.trim();
      }

      if (firstItem is Map<String, dynamic>) {
        final value = firstItem[functionName] as String?;

        if (value != null && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }

    throw StateError('Worker ID was not returned.');
  }

  String? _emptyToNull(String? value) {
    final cleanValue = value?.trim();

    if (cleanValue == null || cleanValue.isEmpty) {
      return null;
    }

    return cleanValue;
  }
}
