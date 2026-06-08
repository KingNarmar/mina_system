import 'package:mina_system/features/demo/data/demo_limits.dart';
import 'package:mina_system/features/demo/data/services/demo_local_storage_service.dart';
import 'package:mina_system/features/demo/data/services/demo_seed_service.dart';
import 'package:mina_system/features/demo/data/services/demo_storage_keys.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/data/repo/tools_repo.dart';

class DemoToolsRepo extends ToolsRepo {
  DemoToolsRepo({
    DemoLocalStorageService storage = const DemoLocalStorageService(),
  }) : _storage = storage;

  final DemoLocalStorageService _storage;

  @override
  Future<List<ToolModel>> getTools({
    required String companyId,
    String? status = 'active',
  }) async {
    final toolsData = await _storage.readJsonList(DemoStorageKeys.tools);
    final cleanStatus = status?.trim().toLowerCase();

    final tools = toolsData
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
        .map(ToolModel.fromJson)
        .toList();

    tools.sort((first, second) {
      return first.toolName.toLowerCase().compareTo(
        second.toolName.toLowerCase(),
      );
    });

    return tools;
  }

  @override
  Future<ToolModel> addTool({required ToolModel tool}) async {
    final toolsData = await _storage.readJsonList(DemoStorageKeys.tools);
    final targetCompanyId = tool.companyId ?? DemoSeedService.demoCompanyId;

    _ensureCanAddTool(toolsData: toolsData, companyId: targetCompanyId);

    final now = DateTime.now().toIso8601String();
    final toolId = tool.id?.trim().isNotEmpty == true
        ? tool.id!.trim()
        : 'demo-tool-${DateTime.now().microsecondsSinceEpoch}';

    final toolToSave = tool.copyWith(
      id: toolId,
      companyId: targetCompanyId,
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

    final savedJson = _toolToJson(toolToSave, createdAt: now, updatedAt: now);

    await _storage.writeJsonList(
      key: DemoStorageKeys.tools,
      value: [...toolsData, savedJson],
    );

    return ToolModel.fromJson(savedJson);
  }

  @override
  Future<ToolModel> updateTool({
    required String toolId,
    required ToolModel tool,
  }) async {
    final toolsData = await _storage.readJsonList(DemoStorageKeys.tools);
    final now = DateTime.now().toIso8601String();

    Map<String, dynamic>? savedJson;

    final updatedTools = toolsData.map((item) {
      if (item['id'] != toolId) {
        return item;
      }

      final createdAt = item['created_at'] as String? ?? now;
      savedJson = _toolToJson(
        tool.copyWith(
          id: toolId,
          companyId: tool.companyId ?? DemoSeedService.demoCompanyId,
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
      throw StateError('Demo tool was not found.');
    }

    await _storage.writeJsonList(
      key: DemoStorageKeys.tools,
      value: updatedTools,
    );

    return ToolModel.fromJson(savedJson!);
  }

  @override
  Future<void> deleteTool({
    required String companyId,
    required String toolId,
  }) async {
    await _updateToolStatus(
      companyId: companyId,
      toolId: toolId,
      status: 'inactive',
    );
  }

  @override
  Future<ToolModel> reactivateTool({
    required String companyId,
    required String toolId,
  }) async {
    return _updateToolStatus(
      companyId: companyId,
      toolId: toolId,
      status: 'active',
    );
  }

  @override
  Future<bool> toolCodeExists({
    required String companyId,
    required String toolCode,
    String? ignoredToolId,
  }) async {
    final tools = await getTools(companyId: companyId, status: null);
    final cleanToolCode = _normalizeValue(toolCode);

    return tools.any((tool) {
      if (ignoredToolId != null && tool.id == ignoredToolId) {
        return false;
      }

      return _normalizeValue(tool.toolCode) == cleanToolCode;
    });
  }

  @override
  Future<bool> toolNameExists({
    required String companyId,
    required String toolName,
    String? ignoredToolId,
  }) async {
    final tools = await getTools(companyId: companyId, status: 'active');
    final cleanToolName = _normalizeValue(toolName);

    return tools.any((tool) {
      if (ignoredToolId != null && tool.id == ignoredToolId) {
        return false;
      }

      return _normalizeValue(tool.toolName) == cleanToolName;
    });
  }

  @override
  Future<String> generateNextToolCode({required String companyId}) async {
    final tools = await getTools(companyId: companyId, status: null);

    var maxNumber = 0;

    for (final tool in tools) {
      final number = _extractEndingNumber(tool.toolCode);

      if (number > maxNumber) {
        maxNumber = number;
      }
    }

    final nextNumber = maxNumber + 1;

    return 'TOOL-${nextNumber.toString().padLeft(3, '0')}';
  }

  Future<ToolModel> _updateToolStatus({
    required String companyId,
    required String toolId,
    required String status,
  }) async {
    final toolsData = await _storage.readJsonList(DemoStorageKeys.tools);
    final now = DateTime.now().toIso8601String();

    Map<String, dynamic>? savedJson;

    final updatedTools = toolsData.map((item) {
      if (item['id'] != toolId || item['company_id'] != companyId) {
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
      throw StateError('Demo tool was not found.');
    }

    await _storage.writeJsonList(
      key: DemoStorageKeys.tools,
      value: updatedTools,
    );

    return ToolModel.fromJson(savedJson!);
  }

  void _ensureCanAddTool({
    required List<Map<String, dynamic>> toolsData,
    required String companyId,
  }) {
    final companyToolsCount = toolsData.where((item) {
      return item['company_id'] == companyId;
    }).length;

    if (companyToolsCount >= DemoLimits.maxTools) {
      throw StateError(DemoLimits.toolsLimitMessage());
    }
  }

  Map<String, dynamic> _toolToJson(
    ToolModel tool, {
    required String createdAt,
    required String updatedAt,
  }) {
    return {
      'id': tool.id,
      'company_id': tool.companyId ?? DemoSeedService.demoCompanyId,
      'tool_code': tool.toolCode,
      'tool_name': tool.toolName,
      'unit_id': tool.unitId,
      'unit_name': tool.unit,
      'category_id': tool.categoryId,
      'category_name': tool.category,
      'description': tool.description,
      'status': tool.status,
      'created_by_profile_id':
          tool.createdByProfileId ?? DemoSeedService.demoProfileId,
      'created_by_profile_name': tool.createdByProfileName ?? 'Demo User',
      'created_by_profile_email':
          tool.createdByProfileEmail ?? 'demo@mina-system.local',
      'updated_by_profile_id':
          tool.updatedByProfileId ?? DemoSeedService.demoProfileId,
      'updated_by_profile_name': tool.updatedByProfileName ?? 'Demo User',
      'updated_by_profile_email':
          tool.updatedByProfileEmail ?? 'demo@mina-system.local',
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String _normalizeValue(String value) {
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
