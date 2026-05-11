import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/worker_model.dart';

class WorkersRepo {
  WorkersRepo({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<List<WorkerModel>> getWorkers({required String companyId}) async {
    final data = await _supabase
        .from('workers')
        .select('''
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
          created_at,
          updated_at,
          departments(name),
          job_titles(name)
        ''')
        .eq('company_id', companyId)
        .eq('status', 'active')
        .order('full_name');

    return data.map((item) {
      return WorkerModel.fromJson(item);
    }).toList();
  }

  Future<WorkerModel> addWorker({required WorkerModel worker}) async {
    final data = await _supabase
        .from('workers')
        .insert(worker.toInsertJson())
        .select('''
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
        created_at,
        updated_at,
        departments(name),
        job_titles(name)
      ''')
        .single();

    return WorkerModel.fromJson(data);
  }

  Future<WorkerModel> updateWorker({
    required String workerId,
    required WorkerModel worker,
  }) async {
    final data = await _supabase
        .from('workers')
        .update(worker.toUpdateJson())
        .eq('id', workerId)
        .select('''
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
        created_at,
        updated_at,
        departments(name),
        job_titles(name)
      ''')
        .single();

    return WorkerModel.fromJson(data);
  }

  Future<void> deleteWorker({required String workerId}) async {
    await _supabase.from('workers').delete().eq('id', workerId);
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
}
