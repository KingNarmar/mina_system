import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_state.dart';

class ToolsCubit extends Cubit<ToolsState> {
  ToolsCubit()
    : super(
        const ToolsState(
          tools: _initialTools,
          filteredTools: _initialTools,
          searchQuery: '',
        ),
      );

  static const List<ToolModel> _initialTools = [
    ToolModel(
      toolCode: 'TOOL-001',
      toolName: 'Grinding Machine',
      unit: 'Each',
      category: 'Power Tools',
      activeCustodyCount: 3,
    ),
    ToolModel(
      toolCode: 'TOOL-002',
      toolName: 'Welding Holder',
      unit: 'Each',
      category: 'Welding Tools',
      activeCustodyCount: 5,
    ),
    ToolModel(
      toolCode: 'TOOL-003',
      toolName: 'Cutting Disc',
      unit: 'Each',
      category: 'Consumables',
      activeCustodyCount: 12,
    ),
    ToolModel(
      toolCode: 'TOOL-004',
      toolName: 'Measuring Tape',
      unit: 'MTR',
      category: 'Measuring Tools',
      activeCustodyCount: 2,
    ),
  ];

  void searchTools(String query) {
    final filteredTools = _filterTools(tools: state.tools, query: query);

    emit(state.copyWith(searchQuery: query, filteredTools: filteredTools));
  }

  void addTool(ToolModel tool) {
    if (isToolCodeAlreadyUsed(tool.toolCode) ||
        isToolNameAlreadyUsed(tool.toolName)) {
      return;
    }

    final updatedTools = List<ToolModel>.from(state.tools)..add(tool);

    emitUpdatedTools(updatedTools);
  }

  void updateTool({
    required String currentToolCode,
    required ToolModel updatedTool,
  }) {
    if (isToolCodeAlreadyUsed(
          updatedTool.toolCode,
          ignoredToolCode: currentToolCode,
        ) ||
        isToolNameAlreadyUsed(
          updatedTool.toolName,
          ignoredToolCode: currentToolCode,
        )) {
      return;
    }

    final updatedTools = state.tools.map((tool) {
      if (_isSameValue(tool.toolCode, currentToolCode)) {
        return updatedTool.copyWith(
          activeCustodyCount: tool.activeCustodyCount,
        );
      }

      return tool;
    }).toList();

    emitUpdatedTools(updatedTools);
  }

  void deleteTool(ToolModel tool) {
    final updatedTools = state.tools.where((item) {
      return !_isSameValue(item.toolCode, tool.toolCode);
    }).toList();

    emitUpdatedTools(updatedTools);
  }

  bool isToolCodeAlreadyUsed(String toolCode, {String? ignoredToolCode}) {
    final normalizedToolCode = _normalizeText(toolCode);
    final normalizedIgnoredToolCode = ignoredToolCode == null
        ? null
        : _normalizeText(ignoredToolCode);

    return state.tools.any((tool) {
      final existingToolCode = _normalizeText(tool.toolCode);

      if (normalizedIgnoredToolCode != null &&
          existingToolCode == normalizedIgnoredToolCode) {
        return false;
      }

      return existingToolCode == normalizedToolCode;
    });
  }

  bool isToolNameAlreadyUsed(String toolName, {String? ignoredToolCode}) {
    final normalizedToolName = _normalizeText(toolName);
    final normalizedIgnoredToolCode = ignoredToolCode == null
        ? null
        : _normalizeText(ignoredToolCode);

    return state.tools.any((tool) {
      final existingToolCode = _normalizeText(tool.toolCode);
      final existingToolName = _normalizeText(tool.toolName);

      if (normalizedIgnoredToolCode != null &&
          existingToolCode == normalizedIgnoredToolCode) {
        return false;
      }

      return existingToolName == normalizedToolName;
    });
  }

  String generateNextToolCode() {
    const prefix = 'TOOL-';
    var maxNumber = 0;

    for (final tool in state.tools) {
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

void updateToolCustodyCount({
  required String toolCode,
  required int change,
}) {
  final updatedTools = state.tools.map((tool) {
    if (_isSameValue(tool.toolCode, toolCode)) {
      final updatedCount = tool.activeCustodyCount + change;

      return tool.copyWith(
        activeCustodyCount: updatedCount < 0 ? 0 : updatedCount,
      );
    }

    return tool;
  }).toList();

  emitUpdatedTools(updatedTools);
}

  void emitUpdatedTools(List<ToolModel> tools) {
    emit(
      state.copyWith(
        tools: tools,
        filteredTools: _filterTools(tools: tools, query: state.searchQuery),
      ),
    );
  }

  List<ToolModel> _filterTools({
    required List<ToolModel> tools,
    required String query,
  }) {
    final searchQuery = _normalizeText(query);

    if (searchQuery.isEmpty) {
      return tools;
    }

    return tools.where((tool) {
      final toolCode = _normalizeText(tool.toolCode);
      final toolName = _normalizeText(tool.toolName);
      final unit = _normalizeText(tool.unit);
      final category = _normalizeText(tool.category);

      return toolCode.contains(searchQuery) ||
          toolName.contains(searchQuery) ||
          unit.contains(searchQuery) ||
          category.contains(searchQuery);
    }).toList();
  }

  bool _isSameValue(String firstValue, String secondValue) {
    return _normalizeText(firstValue) == _normalizeText(secondValue);
  }

  String _normalizeText(String value) {
    return value.trim().toLowerCase();
  }
}
