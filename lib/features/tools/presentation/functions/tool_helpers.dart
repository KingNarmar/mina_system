import 'package:mina_system/features/tools/data/models/tool_model.dart';

String normalizeText(String value) {
  return value.trim().toLowerCase();
}

bool isSameValue(String firstValue, String secondValue) {
  return normalizeText(firstValue) == normalizeText(secondValue);
}

bool checkIsToolCodeAlreadyUsed({
  required List<ToolModel> tools,
  required String toolCode,
  String? ignoredToolCode,
}) {
  final normalizedToolCode = normalizeText(toolCode);
  final normalizedIgnoredToolCode = ignoredToolCode == null
      ? null
      : normalizeText(ignoredToolCode);

  return tools.any((tool) {
    final existingToolCode = normalizeText(tool.toolCode);

    if (normalizedIgnoredToolCode != null &&
        existingToolCode == normalizedIgnoredToolCode) {
      return false;
    }

    return existingToolCode == normalizedToolCode;
  });
}

bool checkIsToolNameAlreadyUsed({
  required List<ToolModel> tools,
  required String toolName,
  String? ignoredToolCode,
}) {
  final normalizedToolName = normalizeText(toolName);
  final normalizedIgnoredToolCode = ignoredToolCode == null
      ? null
      : normalizeText(ignoredToolCode);

  return tools.any((tool) {
    final existingToolCode = normalizeText(tool.toolCode);
    final existingToolName = normalizeText(tool.toolName);

    if (normalizedIgnoredToolCode != null &&
        existingToolCode == normalizedIgnoredToolCode) {
      return false;
    }

    return existingToolName == normalizedToolName;
  });
}

String generateNextToolCodeFromList(List<ToolModel> tools) {
  const prefix = 'TOOL-';
  var maxNumber = 0;

  for (final tool in tools) {
    final toolCode = tool.toolCode.trim().toUpperCase();

    if (!toolCode.startsWith(prefix)) {
      continue;
    }

    final numberPart = toolCode.substring(prefix.length);
    final number = int.tryParse(numberPart);

    if (number != null && number > maxNumber) {
      maxNumber = number;
    }
  }

  final nextNumber = maxNumber + 1;

  return '$prefix${nextNumber.toString().padLeft(3, '0')}';
}

List<ToolModel> filterTools({
  required List<ToolModel> tools,
  required String query,
}) {
  final searchQuery = normalizeText(query);

  if (searchQuery.isEmpty) {
    return tools;
  }

  return tools.where((tool) {
    final toolCode = normalizeText(tool.toolCode);
    final toolName = normalizeText(tool.toolName);
    final unit = normalizeText(tool.unit);
    final category = normalizeText(tool.category);

    return toolCode.contains(searchQuery) ||
        toolName.contains(searchQuery) ||
        unit.contains(searchQuery) ||
        category.contains(searchQuery);
  }).toList();
}

List<ToolModel> sortToolsAlphabetically(List<ToolModel> tools) {
  final sortedTools = List<ToolModel>.from(tools);
  sortedTools.sort(
    (a, b) => a.toolName.toLowerCase().compareTo(b.toolName.toLowerCase()),
  );
  return sortedTools;
}
