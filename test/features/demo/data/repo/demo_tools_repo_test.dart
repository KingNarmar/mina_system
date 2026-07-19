import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mina_system/features/demo/data/demo_limits.dart';
import 'package:mina_system/features/demo/data/repo/demo_tools_repo.dart';
import 'package:mina_system/features/demo/data/services/demo_storage_keys.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DemoToolsRepo', () {
    test('filters by company and status and sorts by tool name', () async {
      _seedTools([
        _toolJson(
          id: 'tool-2',
          companyId: 'company-1',
          toolCode: 'TOOL-002',
          toolName: 'Welding Machine',
        ),
        _toolJson(
          id: 'tool-1',
          companyId: 'company-1',
          toolCode: 'TOOL-001',
          toolName: 'Angle Grinder',
        ),
        _toolJson(
          id: 'tool-3',
          companyId: 'company-1',
          toolCode: 'TOOL-003',
          toolName: 'Inactive Drill',
          status: 'inactive',
        ),
        _toolJson(
          id: 'tool-4',
          companyId: 'company-2',
          toolCode: 'TOOL-001',
          toolName: 'Other Company Tool',
        ),
      ]);

      final repo = DemoToolsRepo();

      final active = await repo.getTools(companyId: 'company-1');
      final inactive = await repo.getTools(
        companyId: 'company-1',
        status: 'inactive',
      );
      final all = await repo.getTools(companyId: 'company-1', status: null);

      expect(active.map((tool) => tool.toolName), [
        'Angle Grinder',
        'Welding Machine',
      ]);
      expect(inactive.single.toolName, 'Inactive Drill');
      expect(all, hasLength(3));
    });

    test('persists add, update, deactivate, and reactivate', () async {
      final repo = DemoToolsRepo();
      const tool = ToolModel(
        companyId: 'company-1',
        toolCode: 'TOOL-001',
        toolName: 'Angle Grinder',
        unit: 'No.',
        category: 'Power Tools',
      );

      final added = await repo.addTool(tool: tool);
      expect(added.id, isNotEmpty);
      expect(
        (await repo.getTools(companyId: 'company-1')).single.toolName,
        'Angle Grinder',
      );

      final updated = await repo.updateTool(
        toolId: added.id!,
        tool: added.copyWith(toolName: 'Updated Grinder'),
      );
      expect(updated.toolName, 'Updated Grinder');

      await repo.deleteTool(companyId: 'company-1', toolId: added.id!);
      expect(await repo.getTools(companyId: 'company-1'), isEmpty);
      expect(
        await repo.getTools(companyId: 'company-1', status: 'inactive'),
        hasLength(1),
      );

      final reactivated = await repo.reactivateTool(
        companyId: 'company-1',
        toolId: added.id!,
      );
      expect(reactivated.status, 'active');
      expect(await repo.getTools(companyId: 'company-1'), hasLength(1));
    });

    test('checks duplicates and generates codes within company data', () async {
      _seedTools([
        _toolJson(
          id: 'tool-1',
          companyId: 'company-1',
          toolCode: 'TOOL-001',
          toolName: 'Angle Grinder',
        ),
        _toolJson(
          id: 'tool-9',
          companyId: 'company-1',
          toolCode: 'TOOL-009',
          toolName: 'Drill Machine',
        ),
        _toolJson(
          id: 'other-tool',
          companyId: 'company-2',
          toolCode: 'TOOL-100',
          toolName: 'Angle Grinder',
        ),
      ]);

      final repo = DemoToolsRepo();

      expect(
        await repo.toolCodeExists(companyId: 'company-1', toolCode: 'tool 001'),
        isTrue,
      );
      expect(
        await repo.toolCodeExists(
          companyId: 'company-1',
          toolCode: 'TOOL-001',
          ignoredToolId: 'tool-1',
        ),
        isFalse,
      );
      expect(
        await repo.toolNameExists(
          companyId: 'company-1',
          toolName: ' angle grinder ',
        ),
        isTrue,
      );
      expect(
        await repo.generateNextToolCode(companyId: 'company-1'),
        'TOOL-010',
      );
    });

    test('enforces the tool limit per company', () async {
      _seedTools([
        for (var index = 1; index <= DemoLimits.maxTools; index++)
          _toolJson(
            id: 'tool-$index',
            companyId: 'company-1',
            toolCode: 'TOOL-${index.toString().padLeft(3, '0')}',
            toolName: 'Tool $index',
          ),
      ]);

      final repo = DemoToolsRepo();

      expect(
        repo.addTool(
          tool: const ToolModel(
            companyId: 'company-1',
            toolCode: 'TOOL-021',
            toolName: 'Tool Twenty One',
            unit: 'No.',
            category: 'Power Tools',
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            DemoLimits.toolsLimitMessage(),
          ),
        ),
      );
    });
  });
}

void _seedTools(List<Map<String, dynamic>> tools) {
  SharedPreferences.setMockInitialValues({
    DemoStorageKeys.tools: jsonEncode(tools),
  });
}

Map<String, dynamic> _toolJson({
  required String id,
  required String companyId,
  required String toolCode,
  required String toolName,
  String status = 'active',
}) {
  return {
    'id': id,
    'company_id': companyId,
    'tool_code': toolCode,
    'tool_name': toolName,
    'unit_id': 'unit-1',
    'unit_name': 'No.',
    'category_id': 'category-1',
    'category_name': 'Power Tools',
    'status': status,
    'created_at': '2026-01-01T00:00:00.000Z',
    'updated_at': '2026-01-01T00:00:00.000Z',
  };
}
