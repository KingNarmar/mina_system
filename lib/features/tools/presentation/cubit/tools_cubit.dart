import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/services/network_status_service.dart';
import 'package:mina_system/core/utils/app_error_message.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/data/repo/tools_repo.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_state.dart';
import 'package:mina_system/features/tools/presentation/functions/tool_helpers.dart';

part 'tools_cubit_add.dart';
part 'tools_cubit_delete.dart';
part 'tools_cubit_update.dart';

class ToolsCubit extends Cubit<ToolsState> {
  ToolsCubit({ToolsRepo? toolsRepo, NetworkStatusService? networkStatusService})
    : _toolsRepo = toolsRepo ?? ToolsRepo(),
      _networkStatusService = networkStatusService ?? NetworkStatusService(),
      super(
        const ToolsState(
          tools: _initialTools,
          filteredTools: _initialTools,
          searchQuery: '',
          statusFilter: 'active',
        ),
      );

  final ToolsRepo _toolsRepo;
  final NetworkStatusService _networkStatusService;

  static const List<ToolModel> _initialTools = [];

  void emitState(ToolsState state) => emit(state);

  Future<void> loadTools({
    required String companyId,
    String? statusFilter,
    bool showLoader = true,
  }) async {
    final selectedStatus = statusFilter ?? state.statusFilter;

    if (showLoader) {
      emit(
        state.copyWith(
          isLoading: true,
          statusFilter: selectedStatus,
          clearErrorMessage: true,
        ),
      );
    } else {
      emit(
        state.copyWith(statusFilter: selectedStatus, clearErrorMessage: true),
      );
    }

    try {
      final tools = await _toolsRepo.getTools(
        companyId: companyId,
        status: selectedStatus,
      );

      emitUpdatedTools(tools, isLoading: false);
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to load tools. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> changeStatusFilter({
    required String companyId,
    required String statusFilter,
  }) async {
    if (statusFilter == state.statusFilter) {
      return;
    }

    emit(
      state.copyWith(
        statusFilter: statusFilter,
        searchQuery: '',
        filteredTools: const [],
      ),
    );

    await loadTools(companyId: companyId, statusFilter: statusFilter);
  }

  void searchTools(String query) {
    final filteredTools = filterTools(tools: state.tools, query: query);

    emit(state.copyWith(searchQuery: query, filteredTools: filteredTools));
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

  void clearErrorMessage() {
    if (state.errorMessage == null) {
      return;
    }

    emit(state.copyWith(clearErrorMessage: true));
  }

  Future<bool> _ensureOnline() async {
    try {
      await _networkStatusService.ensureOnline();
      return true;
    } on NetworkUnavailableException catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.message));
      return false;
    }
  }

  void emitUpdatedTools(
    List<ToolModel> tools, {
    bool? isLoading,
    bool? isSubmitting,
  }) {
    final sortedTools = sortToolsAlphabetically(tools);

    emit(
      state.copyWith(
        tools: sortedTools,
        filteredTools: filterTools(
          tools: sortedTools,
          query: state.searchQuery,
        ),
        isLoading: isLoading,
        isSubmitting: isSubmitting,
        clearErrorMessage: true,
      ),
    );
  }

  ToolModel? _findToolByCode(String toolCode) {
    for (final tool in state.tools) {
      if (isSameValue(tool.toolCode, toolCode)) {
        return tool;
      }
    }

    return null;
  }
}
