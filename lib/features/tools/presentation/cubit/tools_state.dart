import 'package:mina_system/features/tools/data/models/tool_model.dart';

class ToolsState {
  const ToolsState({
    required this.tools,
    required this.filteredTools,
    required this.searchQuery,
  });

  final List<ToolModel> tools;
  final List<ToolModel> filteredTools;
  final String searchQuery;

  ToolsState copyWith({
    List<ToolModel>? tools,
    List<ToolModel>? filteredTools,
    String? searchQuery,
  }) {
    return ToolsState(
      tools: tools ?? this.tools,
      filteredTools: filteredTools ?? this.filteredTools,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}