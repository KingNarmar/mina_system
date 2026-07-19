import 'package:flutter_test/flutter_test.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/presentation/functions/tool_form_validators.dart';

void main() {
  group('tool form validators', () {
    const initialTool = ToolModel(
      id: 'tool-1',
      companyId: 'company-1',
      toolCode: 'TOOL-001',
      toolName: 'Angle Grinder',
      unit: 'No.',
      category: 'Power Tools',
    );

    test('requires text and dropdown values', () {
      expect(validateRequiredText('  '), 'This field is required');
      expect(validateRequiredDropdown(null), 'Please select a value');
      expect(validateRequiredText('value'), isNull);
      expect(validateRequiredDropdown('value'), isNull);
    });

    test('passes trimmed code and ignored code to duplicate check', () {
      String? receivedCode;
      String? receivedIgnoredCode;

      final result = validateToolCode(
        value: ' TOOL-001 ',
        initialTool: initialTool,
        isToolCodeAlreadyUsed: (toolCode, {ignoredToolCode}) {
          receivedCode = toolCode;
          receivedIgnoredCode = ignoredToolCode;
          return true;
        },
      );

      expect(receivedCode, 'TOOL-001');
      expect(receivedIgnoredCode, 'TOOL-001');
      expect(result, 'Tool Code already exists');
    });

    test('passes trimmed name and ignored code to duplicate check', () {
      String? receivedName;
      String? receivedIgnoredCode;

      final result = validateToolName(
        value: ' Angle Grinder ',
        initialTool: initialTool,
        isToolNameAlreadyUsed: (toolName, {ignoredToolCode}) {
          receivedName = toolName;
          receivedIgnoredCode = ignoredToolCode;
          return true;
        },
      );

      expect(receivedName, 'Angle Grinder');
      expect(receivedIgnoredCode, 'TOOL-001');
      expect(result, 'Tool Name already exists');
    });

    test('accepts unique code and name', () {
      expect(
        validateToolCode(
          value: 'TOOL-002',
          initialTool: null,
          isToolCodeAlreadyUsed: (_, {ignoredToolCode}) => false,
        ),
        isNull,
      );
      expect(
        validateToolName(
          value: 'Drill',
          initialTool: null,
          isToolNameAlreadyUsed: (_, {ignoredToolCode}) => false,
        ),
        isNull,
      );
    });
  });
}
