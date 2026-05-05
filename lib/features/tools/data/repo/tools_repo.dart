import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/tool_model.dart';

class ToolsRepo {
  ToolsRepo({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<List<ToolModel>> getTools({required String companyId}) async {
    final data = await _supabase
        .from('tools')
        .select('''
          id,
          company_id,
          tool_code,
          tool_name,
          unit_id,
          category_id,
          description,
          status,
          created_by_profile_id,
          created_at,
          updated_at,
          tool_units!tools_unit_fk(name),
          tool_categories!tools_category_fk(name)
        ''')
        .eq('company_id', companyId)
        .eq('status', 'active')
        .order('tool_name');

    return data.map((item) {
      return ToolModel.fromJson(item);
    }).toList();
  }

  Future<ToolModel> addTool({required ToolModel tool}) async {
    final data = await _supabase
        .from('tools')
        .insert(tool.toInsertJson())
        .select('''
          id,
          company_id,
          tool_code,
          tool_name,
          unit_id,
          category_id,
          description,
          status,
          created_by_profile_id,
          created_at,
          updated_at,
          tool_units!tools_unit_fk(name),
          tool_categories!tools_category_fk(name)
        ''')
        .single();

    return ToolModel.fromJson(data);
  }

  Future<ToolModel> updateTool({
    required String toolId,
    required ToolModel tool,
  }) async {
    final data = await _supabase
        .from('tools')
        .update(tool.toUpdateJson())
        .eq('id', toolId)
        .select('''
          id,
          company_id,
          tool_code,
          tool_name,
          unit_id,
          category_id,
          description,
          status,
          created_by_profile_id,
          created_at,
          updated_at,
          tool_units!tools_unit_fk(name),
          tool_categories!tools_category_fk(name)
        ''')
        .single();

    return ToolModel.fromJson(data);
  }

  Future<void> deleteTool({required String toolId}) async {
    await _supabase.from('tools').delete().eq('id', toolId);
  }

  Future<bool> toolCodeExists({
    required String companyId,
    required String toolCode,
    String? ignoredToolId,
  }) async {
    final cleanToolCode = toolCode.trim();

    if (cleanToolCode.isEmpty) {
      return false;
    }

    final data = await _supabase
        .from('tools')
        .select('id, tool_code')
        .eq('company_id', companyId);

    return data.any((item) {
      final toolId = item['id'] as String?;
      final existingToolCode = item['tool_code'] as String?;

      if (ignoredToolId != null && toolId == ignoredToolId) {
        return false;
      }

      return _isSameToolValue(existingToolCode, cleanToolCode);
    });
  }

  Future<bool> toolNameExists({
    required String companyId,
    required String toolName,
    String? ignoredToolId,
  }) async {
    final cleanToolName = toolName.trim();

    if (cleanToolName.isEmpty) {
      return false;
    }

    final data = await _supabase
        .from('tools')
        .select('id, tool_name')
        .eq('company_id', companyId)
        .eq('status', 'active');

    return data.any((item) {
      final toolId = item['id'] as String?;
      final existingToolName = item['tool_name'] as String?;

      if (ignoredToolId != null && toolId == ignoredToolId) {
        return false;
      }

      return _isSameToolValue(existingToolName, cleanToolName);
    });
  }

  Future<String> generateNextToolCode({required String companyId}) async {
    final data = await _supabase
        .from('tools')
        .select('tool_code')
        .eq('company_id', companyId);

    var maxNumber = 0;

    for (final item in data) {
      final toolCode = item['tool_code'] as String?;
      final number = _extractEndingNumber(toolCode);

      if (number > maxNumber) {
        maxNumber = number;
      }
    }

    final nextNumber = maxNumber + 1;
    return 'TOOL-${nextNumber.toString().padLeft(3, '0')}';
  }

  bool _isSameToolValue(String? firstValue, String secondValue) {
    if (firstValue == null) {
      return false;
    }

    return _normalizeToolValue(firstValue) == _normalizeToolValue(secondValue);
  }

  String _normalizeToolValue(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
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