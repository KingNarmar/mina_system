import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_state.dart';
import 'package:mina_system/features/tools/presentation/functions/tool_helpers.dart';

class ToolsCubit extends Cubit<ToolsState> {
  ToolsCubit()
    : super(
        const ToolsState(
          tools: _initialTools,
          filteredTools: _initialTools,
          searchQuery: '',
        ),
      );

  static const List<ToolModel> _initialTools = [];

  void searchTools(String query) {
    final filteredTools = filterTools(tools: state.tools, query: query);

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
      if (isSameValue(tool.toolCode, currentToolCode)) {
        return updatedTool;
      }

      return tool;
    }).toList();

    emitUpdatedTools(updatedTools);
  }

  void deleteTool(ToolModel tool) {
    final updatedTools = state.tools.where((item) {
      return !isSameValue(item.toolCode, tool.toolCode);
    }).toList();

    emitUpdatedTools(updatedTools);
  }

  bool isToolCodeAlreadyUsed(String toolCode, {String? ignoredToolCode}) {
    return checkIsToolCodeAlreadyUsed(
      tools: state.tools,
      toolCode: toolCode,
      ignoredToolCode: ignoredToolCode,
    );
  }

  bool isToolNameAlreadyUsed(String toolName, {String? ignoredToolCode}) {
    return checkIsToolNameAlreadyUsed(
      tools: state.tools,
      toolName: toolName,
      ignoredToolCode: ignoredToolCode,
    );
  }

  String generateNextToolCode() {
    return generateNextToolCodeFromList(state.tools);
  }

  void emitUpdatedTools(List<ToolModel> tools) {
    emit(
      state.copyWith(
        tools: tools,
        filteredTools: filterTools(tools: tools, query: state.searchQuery),
      ),
    );
  }
}
