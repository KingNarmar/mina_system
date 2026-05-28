import 'package:mina_system/features/tools/data/models/tool_model.dart';

class ToolsSubmissionKeys {
  const ToolsSubmissionKeys._();

  static const String add = 'tools:add';

  static String update(String toolCode) {
    return 'tools:update:$toolCode';
  }

  static String delete(String toolCode) {
    return 'tools:delete:$toolCode';
  }

  static String reactivate(String toolCode) {
    return 'tools:reactivate:$toolCode';
  }
}

class ToolsState {
  const ToolsState({
    required this.tools,
    required this.filteredTools,
    required this.searchQuery,
    this.statusFilter = 'active',
    this.isLoading = false,
    this.isSubmitting = false,
    this.submittingActionKey,
    this.errorMessage,
  });

  final List<ToolModel> tools;
  final List<ToolModel> filteredTools;
  final String searchQuery;
  final String statusFilter;
  final bool isLoading;
  final bool isSubmitting;
  final String? submittingActionKey;
  final String? errorMessage;

  bool isActionSubmitting(String actionKey) {
    return isSubmitting && submittingActionKey == actionKey;
  }

  ToolsState copyWith({
    List<ToolModel>? tools,
    List<ToolModel>? filteredTools,
    String? searchQuery,
    String? statusFilter,
    bool? isLoading,
    bool? isSubmitting,
    String? submittingActionKey,
    String? errorMessage,
    bool clearSubmittingActionKey = false,
    bool clearErrorMessage = false,
  }) {
    final nextIsSubmitting = isSubmitting ?? this.isSubmitting;

    return ToolsState(
      tools: tools ?? this.tools,
      filteredTools: filteredTools ?? this.filteredTools,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: nextIsSubmitting,
      submittingActionKey: clearSubmittingActionKey || !nextIsSubmitting
          ? null
          : submittingActionKey ?? this.submittingActionKey,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
