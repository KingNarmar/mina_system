import 'package:mina_system/features/tools/data/models/tool_model.dart';

class ToolsState {
  const ToolsState({
    required this.tools,
    required this.filteredTools,
    required this.searchQuery,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final List<ToolModel> tools;
  final List<ToolModel> filteredTools;
  final String searchQuery;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  ToolsState copyWith({
    List<ToolModel>? tools,
    List<ToolModel>? filteredTools,
    String? searchQuery,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ToolsState(
      tools: tools ?? this.tools,
      filteredTools: filteredTools ?? this.filteredTools,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}