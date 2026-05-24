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
    bool isActive = true,
  }) async {
    final data = await _supabase
        .from('departments')
        .select()
        .eq('company_id', companyId)
        .eq('is_active', isActive)
        .order('name');

    return data.map((item) {
      return DepartmentModel.fromJson(item);
    }).toList();
  }

  Future<List<DepartmentModel>> getInactiveDepartments({
    required String companyId,
  }) async {
    return getDepartments(companyId: companyId, isActive: false);
  }

  Future<DepartmentModel> addDepartment({
    required String companyId,
    required String name,
    String? code,
  }) async {
    final cleanCompanyId = companyId.trim();
    final cleanName = name.trim();

    if (cleanCompanyId.isEmpty) {
      throw StateError('Company ID was not found.');
    }

    if (cleanName.isEmpty) {
      throw StateError('Department name is required.');
    }

    final rpcResult = await _supabase.rpc(
      'create_department',
      params: {
        'p_company_id': cleanCompanyId,
        'p_name': cleanName,
        'p_code': _emptyToNull(code),
      },
    );

    final departmentId = _readRpcUuidResult(
      rpcResult,
      'create_department',
      'Department ID was not returned.',
    );

    return _getDepartmentByIdAndCompany(
      departmentId: departmentId,
      companyId: cleanCompanyId,
    );
  }

  Future<void> deleteDepartment({required String departmentId}) async {
    final department = await _getDepartmentById(departmentId: departmentId);

    await _supabase.rpc(
      'deactivate_department',
      params: {
        'p_company_id': department.companyId,
        'p_department_id': department.id,
      },
    );
  }

  Future<DepartmentModel> reactivateDepartment({
    required String departmentId,
  }) async {
    final department = await _getDepartmentById(departmentId: departmentId);

    final rpcResult = await _supabase.rpc(
      'reactivate_department',
      params: {
        'p_company_id': department.companyId,
        'p_department_id': department.id,
      },
    );

    final savedDepartmentId = _readRpcUuidResult(
      rpcResult,
      'reactivate_department',
      'Department ID was not returned.',
    );

    return _getDepartmentByIdAndCompany(
      departmentId: savedDepartmentId,
      companyId: department.companyId,
    );
  }

  Future<List<JobTitleModel>> getJobTitles({
    required String companyId,
    bool isActive = true,
  }) async {
    final data = await _supabase
        .from('job_titles')
        .select()
        .eq('company_id', companyId)
        .eq('is_active', isActive)
        .order('name');

    return data.map((item) {
      return JobTitleModel.fromJson(item);
    }).toList();
  }

  Future<List<JobTitleModel>> getInactiveJobTitles({
    required String companyId,
  }) async {
    return getJobTitles(companyId: companyId, isActive: false);
  }

  Future<JobTitleModel> addJobTitle({
    required String companyId,
    required String departmentId,
    required String name,
  }) async {
    final cleanCompanyId = companyId.trim();
    final cleanDepartmentId = departmentId.trim();
    final cleanName = name.trim();

    if (cleanCompanyId.isEmpty) {
      throw StateError('Company ID was not found.');
    }

    if (cleanDepartmentId.isEmpty) {
      throw StateError('Department was not found.');
    }

    if (cleanName.isEmpty) {
      throw StateError('Job title name is required.');
    }

    final rpcResult = await _supabase.rpc(
      'create_job_title',
      params: {
        'p_company_id': cleanCompanyId,
        'p_department_id': cleanDepartmentId,
        'p_name': cleanName,
      },
    );

    final jobTitleId = _readRpcUuidResult(
      rpcResult,
      'create_job_title',
      'Job title ID was not returned.',
    );

    return _getJobTitleByIdAndCompany(
      jobTitleId: jobTitleId,
      companyId: cleanCompanyId,
    );
  }

  Future<void> deleteJobTitle({required String jobTitleId}) async {
    final jobTitle = await _getJobTitleById(jobTitleId: jobTitleId);

    await _supabase.rpc(
      'deactivate_job_title',
      params: {
        'p_company_id': jobTitle.companyId,
        'p_job_title_id': jobTitle.id,
      },
    );
  }

  Future<JobTitleModel> reactivateJobTitle({required String jobTitleId}) async {
    final jobTitle = await _getJobTitleById(jobTitleId: jobTitleId);

    final rpcResult = await _supabase.rpc(
      'reactivate_job_title',
      params: {
        'p_company_id': jobTitle.companyId,
        'p_job_title_id': jobTitle.id,
      },
    );

    final savedJobTitleId = _readRpcUuidResult(
      rpcResult,
      'reactivate_job_title',
      'Job title ID was not returned.',
    );

    return _getJobTitleByIdAndCompany(
      jobTitleId: savedJobTitleId,
      companyId: jobTitle.companyId,
    );
  }

  Future<List<ToolUnitModel>> getToolUnits({
    required String companyId,
    bool isActive = true,
  }) async {
    final data = await _supabase
        .from('tool_units')
        .select()
        .eq('company_id', companyId)
        .eq('is_active', isActive)
        .order('name');

    return data.map((item) {
      return ToolUnitModel.fromJson(item);
    }).toList();
  }

  Future<List<ToolUnitModel>> getInactiveToolUnits({
    required String companyId,
  }) async {
    return getToolUnits(companyId: companyId, isActive: false);
  }

  Future<ToolUnitModel> addToolUnit({
    required String companyId,
    required String name,
    String? symbol,
  }) async {
    final cleanCompanyId = companyId.trim();
    final cleanName = name.trim();

    if (cleanCompanyId.isEmpty) {
      throw StateError('Company ID was not found.');
    }

    if (cleanName.isEmpty) {
      throw StateError('Tool unit name is required.');
    }

    final rpcResult = await _supabase.rpc(
      'create_tool_unit',
      params: {
        'p_company_id': cleanCompanyId,
        'p_name': cleanName,
        'p_symbol': _emptyToNull(symbol),
      },
    );

    final toolUnitId = _readRpcUuidResult(
      rpcResult,
      'create_tool_unit',
      'Tool unit ID was not returned.',
    );

    return _getToolUnitByIdAndCompany(
      toolUnitId: toolUnitId,
      companyId: cleanCompanyId,
    );
  }

  Future<void> deleteToolUnit({required String toolUnitId}) async {
    final toolUnit = await _getToolUnitById(toolUnitId: toolUnitId);

    await _supabase.rpc(
      'deactivate_tool_unit',
      params: {
        'p_company_id': toolUnit.companyId,
        'p_tool_unit_id': toolUnit.id,
      },
    );
  }

  Future<ToolUnitModel> reactivateToolUnit({required String toolUnitId}) async {
    final toolUnit = await _getToolUnitById(toolUnitId: toolUnitId);

    final rpcResult = await _supabase.rpc(
      'reactivate_tool_unit',
      params: {
        'p_company_id': toolUnit.companyId,
        'p_tool_unit_id': toolUnit.id,
      },
    );

    final savedToolUnitId = _readRpcUuidResult(
      rpcResult,
      'reactivate_tool_unit',
      'Tool unit ID was not returned.',
    );

    return _getToolUnitByIdAndCompany(
      toolUnitId: savedToolUnitId,
      companyId: toolUnit.companyId,
    );
  }

  Future<List<ToolCategoryModel>> getToolCategories({
    required String companyId,
    bool isActive = true,
  }) async {
    final data = await _supabase
        .from('tool_categories')
        .select()
        .eq('company_id', companyId)
        .eq('is_active', isActive)
        .order('name');

    return data.map((item) {
      return ToolCategoryModel.fromJson(item);
    }).toList();
  }

  Future<List<ToolCategoryModel>> getInactiveToolCategories({
    required String companyId,
  }) async {
    return getToolCategories(companyId: companyId, isActive: false);
  }

  Future<ToolCategoryModel> addToolCategory({
    required String companyId,
    required String name,
    String? code,
  }) async {
    final cleanCompanyId = companyId.trim();
    final cleanName = name.trim();

    if (cleanCompanyId.isEmpty) {
      throw StateError('Company ID was not found.');
    }

    if (cleanName.isEmpty) {
      throw StateError('Tool category name is required.');
    }

    final rpcResult = await _supabase.rpc(
      'create_tool_category',
      params: {
        'p_company_id': cleanCompanyId,
        'p_name': cleanName,
        'p_code': _emptyToNull(code),
      },
    );

    final toolCategoryId = _readRpcUuidResult(
      rpcResult,
      'create_tool_category',
      'Tool category ID was not returned.',
    );

    return _getToolCategoryByIdAndCompany(
      toolCategoryId: toolCategoryId,
      companyId: cleanCompanyId,
    );
  }

  Future<void> deleteToolCategory({required String toolCategoryId}) async {
    final toolCategory = await _getToolCategoryById(
      toolCategoryId: toolCategoryId,
    );

    await _supabase.rpc(
      'deactivate_tool_category',
      params: {
        'p_company_id': toolCategory.companyId,
        'p_tool_category_id': toolCategory.id,
      },
    );
  }

  Future<ToolCategoryModel> reactivateToolCategory({
    required String toolCategoryId,
  }) async {
    final toolCategory = await _getToolCategoryById(
      toolCategoryId: toolCategoryId,
    );

    final rpcResult = await _supabase.rpc(
      'reactivate_tool_category',
      params: {
        'p_company_id': toolCategory.companyId,
        'p_tool_category_id': toolCategory.id,
      },
    );

    final savedToolCategoryId = _readRpcUuidResult(
      rpcResult,
      'reactivate_tool_category',
      'Tool category ID was not returned.',
    );

    return _getToolCategoryByIdAndCompany(
      toolCategoryId: savedToolCategoryId,
      companyId: toolCategory.companyId,
    );
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

  Future<DepartmentModel> _getDepartmentById({
    required String departmentId,
  }) async {
    final cleanDepartmentId = departmentId.trim();

    if (cleanDepartmentId.isEmpty) {
      throw StateError('Department ID was not found.');
    }

    final data = await _supabase
        .from('departments')
        .select()
        .eq('id', cleanDepartmentId)
        .single();

    return DepartmentModel.fromJson(data);
  }

  Future<DepartmentModel> _getDepartmentByIdAndCompany({
    required String departmentId,
    required String companyId,
  }) async {
    final data = await _supabase
        .from('departments')
        .select()
        .eq('id', departmentId)
        .eq('company_id', companyId)
        .single();

    return DepartmentModel.fromJson(data);
  }

  Future<JobTitleModel> _getJobTitleById({required String jobTitleId}) async {
    final cleanJobTitleId = jobTitleId.trim();

    if (cleanJobTitleId.isEmpty) {
      throw StateError('Job title ID was not found.');
    }

    final data = await _supabase
        .from('job_titles')
        .select()
        .eq('id', cleanJobTitleId)
        .single();

    return JobTitleModel.fromJson(data);
  }

  Future<JobTitleModel> _getJobTitleByIdAndCompany({
    required String jobTitleId,
    required String companyId,
  }) async {
    final data = await _supabase
        .from('job_titles')
        .select()
        .eq('id', jobTitleId)
        .eq('company_id', companyId)
        .single();

    return JobTitleModel.fromJson(data);
  }

  Future<ToolUnitModel> _getToolUnitById({required String toolUnitId}) async {
    final cleanToolUnitId = toolUnitId.trim();

    if (cleanToolUnitId.isEmpty) {
      throw StateError('Tool unit ID was not found.');
    }

    final data = await _supabase
        .from('tool_units')
        .select()
        .eq('id', cleanToolUnitId)
        .single();

    return ToolUnitModel.fromJson(data);
  }

  Future<ToolUnitModel> _getToolUnitByIdAndCompany({
    required String toolUnitId,
    required String companyId,
  }) async {
    final data = await _supabase
        .from('tool_units')
        .select()
        .eq('id', toolUnitId)
        .eq('company_id', companyId)
        .single();

    return ToolUnitModel.fromJson(data);
  }

  Future<ToolCategoryModel> _getToolCategoryById({
    required String toolCategoryId,
  }) async {
    final cleanToolCategoryId = toolCategoryId.trim();

    if (cleanToolCategoryId.isEmpty) {
      throw StateError('Tool category ID was not found.');
    }

    final data = await _supabase
        .from('tool_categories')
        .select()
        .eq('id', cleanToolCategoryId)
        .single();

    return ToolCategoryModel.fromJson(data);
  }

  Future<ToolCategoryModel> _getToolCategoryByIdAndCompany({
    required String toolCategoryId,
    required String companyId,
  }) async {
    final data = await _supabase
        .from('tool_categories')
        .select()
        .eq('id', toolCategoryId)
        .eq('company_id', companyId)
        .single();

    return ToolCategoryModel.fromJson(data);
  }

  String _readRpcUuidResult(
    dynamic rpcResult,
    String functionName,
    String fallbackErrorMessage,
  ) {
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

    throw StateError(fallbackErrorMessage);
  }

  String? _emptyToNull(String? value) {
    final cleanValue = value?.trim();

    if (cleanValue == null || cleanValue.isEmpty) {
      return null;
    }

    return cleanValue;
  }

  bool _isSameLookupName(String? firstValue, String secondValue) {
    if (firstValue == null) {
      return false;
    }

    return _normalizeLookupName(firstValue) ==
        _normalizeLookupName(secondValue);
  }

  String _normalizeLookupName(String value) {
    return value.trim().toLowerCase().replaceAll(
      RegExp(r'[^\p{L}\p{N}]+', unicode: true),
      '',
    );
  }
}
