import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/department_model.dart';
import '../models/job_title_model.dart';
import '../models/tool_category_model.dart';
import '../models/tool_unit_model.dart';

class LookupsRepo {
  LookupsRepo({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<List<DepartmentModel>> getDepartments({
    required String companyId,
  }) async {
    final data = await _supabase
        .from('departments')
        .select()
        .eq('company_id', companyId)
        .eq('is_active', true)
        .order('name');

    return data.map((item) {
      return DepartmentModel.fromJson(item);
    }).toList();
  }

  Future<DepartmentModel> addDepartment({
    required String companyId,
    required String name,
    String? code,
  }) async {
    final cleanName = name.trim();
    final cleanCode = code?.trim();

    final data = await _supabase
        .from('departments')
        .insert({
          'company_id': companyId,
          'name': cleanName,
          'code': cleanCode?.isEmpty ?? true ? null : cleanCode,
          'is_active': true,
        })
        .select()
        .single();

    return DepartmentModel.fromJson(data);
  }

  Future<void> deleteDepartment({required String departmentId}) async {
    await _supabase.from('departments').delete().eq('id', departmentId);
  }

  Future<List<JobTitleModel>> getJobTitles({required String companyId}) async {
    final data = await _supabase
        .from('job_titles')
        .select()
        .eq('company_id', companyId)
        .eq('is_active', true)
        .order('name');

    return data.map((item) {
      return JobTitleModel.fromJson(item);
    }).toList();
  }

  Future<JobTitleModel> addJobTitle({
    required String companyId,
    required String departmentId,
    required String name,
  }) async {
    final cleanName = name.trim();

    final data = await _supabase
        .from('job_titles')
        .insert({
          'company_id': companyId,
          'department_id': departmentId,
          'name': cleanName,
          'is_active': true,
        })
        .select()
        .single();

    return JobTitleModel.fromJson(data);
  }

  Future<void> deleteJobTitle({required String jobTitleId}) async {
    await _supabase.from('job_titles').delete().eq('id', jobTitleId);
  }

  Future<List<ToolUnitModel>> getToolUnits({required String companyId}) async {
    final data = await _supabase
        .from('tool_units')
        .select()
        .eq('company_id', companyId)
        .eq('is_active', true)
        .order('name');

    return data.map((item) {
      return ToolUnitModel.fromJson(item);
    }).toList();
  }

  Future<ToolUnitModel> addToolUnit({
    required String companyId,
    required String name,
    String? symbol,
  }) async {
    final cleanName = name.trim();
    final cleanSymbol = symbol?.trim();

    final data = await _supabase
        .from('tool_units')
        .insert({
          'company_id': companyId,
          'name': cleanName,
          'symbol': cleanSymbol?.isEmpty ?? true ? null : cleanSymbol,
          'is_active': true,
        })
        .select()
        .single();

    return ToolUnitModel.fromJson(data);
  }

  Future<void> deleteToolUnit({required String toolUnitId}) async {
    await _supabase.from('tool_units').delete().eq('id', toolUnitId);
  }

  Future<List<ToolCategoryModel>> getToolCategories({
    required String companyId,
  }) async {
    final data = await _supabase
        .from('tool_categories')
        .select()
        .eq('company_id', companyId)
        .eq('is_active', true)
        .order('name');

    return data.map((item) {
      return ToolCategoryModel.fromJson(item);
    }).toList();
  }

  Future<ToolCategoryModel> addToolCategory({
    required String companyId,
    required String name,
    String? code,
  }) async {
    final cleanName = name.trim();
    final cleanCode = code?.trim();

    final data = await _supabase
        .from('tool_categories')
        .insert({
          'company_id': companyId,
          'name': cleanName,
          'code': cleanCode?.isEmpty ?? true ? null : cleanCode,
          'is_active': true,
        })
        .select()
        .single();

    return ToolCategoryModel.fromJson(data);
  }

  Future<void> deleteToolCategory({required String toolCategoryId}) async {
    await _supabase.from('tool_categories').delete().eq('id', toolCategoryId);
  }

  Future<bool> departmentNameExists({
    required String companyId,
    required String name,
  }) async {
    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      return false;
    }

    final data = await _supabase
        .from('departments')
        .select('id, name')
        .eq('company_id', companyId)
        .eq('is_active', true);

    return data.any((item) {
      return _isSameLookupName(item['name'] as String?, cleanName);
    });
  }

  Future<bool> jobTitleNameExists({
    required String companyId,
    required String departmentId,
    required String name,
  }) async {
    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      return false;
    }

    final data = await _supabase
        .from('job_titles')
        .select('id, name')
        .eq('company_id', companyId)
        .eq('department_id', departmentId)
        .eq('is_active', true);

    return data.any((item) {
      return _isSameLookupName(item['name'] as String?, cleanName);
    });
  }

  Future<bool> toolUnitNameExists({
    required String companyId,
    required String name,
  }) async {
    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      return false;
    }

    final data = await _supabase
        .from('tool_units')
        .select('id, name')
        .eq('company_id', companyId)
        .eq('is_active', true);

    return data.any((item) {
      return _isSameLookupName(item['name'] as String?, cleanName);
    });
  }

  Future<bool> toolCategoryNameExists({
    required String companyId,
    required String name,
  }) async {
    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      return false;
    }

    final data = await _supabase
        .from('tool_categories')
        .select('id, name')
        .eq('company_id', companyId)
        .eq('is_active', true);

    return data.any((item) {
      return _isSameLookupName(item['name'] as String?, cleanName);
    });
  }

  bool _isSameLookupName(String? firstValue, String secondValue) {
    if (firstValue == null) {
      return false;
    }

    return _normalizeLookupName(firstValue) ==
        _normalizeLookupName(secondValue);
  }

  String _normalizeLookupName(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }
}
