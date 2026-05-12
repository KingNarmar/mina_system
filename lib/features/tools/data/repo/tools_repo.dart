import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/tool_model.dart';

class ToolsRepo {
  ToolsRepo({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  static const String _toolSelectColumns = '''
    id,
    company_id,
    tool_code,
    tool_name,
    unit_id,
    category_id,
    description,
    status,
    created_by_profile_id,
    updated_by_profile_id,
    created_at,
    updated_at,
    tool_units!tools_unit_fk(name),
    tool_categories!tools_category_fk(name)
  ''';

  Future<List<ToolModel>> getTools({required String companyId}) async {
    final data = await _supabase
        .from('tools')
        .select(_toolSelectColumns)
        .eq('company_id', companyId)
        .eq('status', 'active')
        .order('tool_name');

    return data.map((item) {
      return ToolModel.fromJson(item);
    }).toList();
  }

  Future<ToolModel> addTool({required ToolModel tool}) async {
    final companyId = tool.companyId;

    if (companyId == null || companyId.trim().isEmpty) {
      throw StateError('Company ID was not found.');
    }

    if (tool.toolCode.trim().isEmpty) {
      throw StateError('Tool code was not found.');
    }

    if (tool.unitId == null || tool.unitId!.trim().isEmpty) {
      throw StateError('Tool unit was not found.');
    }

    if (tool.categoryId == null || tool.categoryId!.trim().isEmpty) {
      throw StateError('Tool category was not found.');
    }

    final rpcResult = await _supabase.rpc(
      'create_tool',
      params: {
        'p_company_id': companyId,
        'p_tool_code': tool.toolCode.trim(),
        'p_tool_name': tool.toolName.trim(),
        'p_unit_id': tool.unitId,
        'p_category_id': tool.categoryId,
        'p_description': _emptyToNull(tool.description),
      },
    );

    final toolId = _readRpcUuidResult(rpcResult, 'create_tool');

    final data = await _supabase
        .from('tools')
        .select(_toolSelectColumns)
        .eq('id', toolId)
        .eq('company_id', companyId)
        .single();

    return ToolModel.fromJson(data);
  }

  Future<ToolModel> updateTool({
    required String toolId,
    required ToolModel tool,
  }) async {
    final companyId = tool.companyId;

    if (companyId == null || companyId.trim().isEmpty) {
      throw StateError('Company ID was not found.');
    }

    if (tool.toolCode.trim().isEmpty) {
      throw StateError('Tool code was not found.');
    }

    if (tool.unitId == null || tool.unitId!.trim().isEmpty) {
      throw StateError('Tool unit was not found.');
    }

    if (tool.categoryId == null || tool.categoryId!.trim().isEmpty) {
      throw StateError('Tool category was not found.');
    }

    final rpcResult = await _supabase.rpc(
      'update_tool',
      params: {
        'p_company_id': companyId,
        'p_tool_id': toolId,
        'p_tool_code': tool.toolCode.trim(),
        'p_tool_name': tool.toolName.trim(),
        'p_unit_id': tool.unitId,
        'p_category_id': tool.categoryId,
        'p_description': _emptyToNull(tool.description),
        'p_status': tool.status,
      },
    );

    final savedToolId = _readRpcUuidResult(rpcResult, 'update_tool');

    final data = await _supabase
        .from('tools')
        .select(_toolSelectColumns)
        .eq('id', savedToolId)
        .eq('company_id', companyId)
        .single();

    return ToolModel.fromJson(data);
  }

  Future<void> deleteTool({
  required String companyId,
  required String toolId,
}) async {
  if (companyId.trim().isEmpty) {
    throw StateError('Company ID was not found.');
  }

  if (toolId.trim().isEmpty) {
    throw StateError('Tool ID was not found.');
  }

  await _supabase.rpc(
    'deactivate_tool',
    params: {
      'p_company_id': companyId,
      'p_tool_id': toolId,
    },
  );
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

    throw StateError('Tool ID was not returned.');
  }

  String? _emptyToNull(String? value) {
    final cleanValue = value?.trim();

    if (cleanValue == null || cleanValue.isEmpty) {
      return null;
    }

    return cleanValue;
  }
}
