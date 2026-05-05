import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/data/repo/tools_repo.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_state.dart';
import 'package:mina_system/features/tools/presentation/functions/tool_helpers.dart';

class ToolsCubit extends Cubit<ToolsState> {
  ToolsCubit({ToolsRepo? toolsRepo})
    : _toolsRepo = toolsRepo ?? ToolsRepo(),
      super(
        const ToolsState(
          tools: _initialTools,
          filteredTools: _initialTools,
          searchQuery: '',
        ),
      );

  final ToolsRepo _toolsRepo;

  static const List<ToolModel> _initialTools = [];

  Future<void> loadTools({required String companyId}) async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    try {
      final tools = await _toolsRepo.getTools(companyId: companyId);

      emitUpdatedTools(tools, isLoading: false);
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  void searchTools(String query) {
    final filteredTools = filterTools(tools: state.tools, query: query);

    emit(state.copyWith(searchQuery: query, filteredTools: filteredTools));
  }

  Future<bool> addTool(
    ToolModel tool, {
    String? companyId,
    String? createdByProfileId,
  }) async {
    final cleanToolName = tool.toolName.trim();

    if (companyId == null || companyId.isEmpty) {
      emit(state.copyWith(errorMessage: 'Company ID was not found'));
      return false;
    }

    if (createdByProfileId == null || createdByProfileId.isEmpty) {
      emit(state.copyWith(errorMessage: 'Profile ID was not found'));
      return false;
    }

    if (cleanToolName.isEmpty) {
      return false;
    }

    if (tool.unitId == null || tool.categoryId == null) {
      emit(state.copyWith(errorMessage: 'Unit and category are required'));
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final isDuplicatedToolName = await _toolsRepo.toolNameExists(
        companyId: companyId,
        toolName: cleanToolName,
      );

      if (isDuplicatedToolName) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: 'Tool name already exists',
          ),
        );
        return false;
      }

      final toolCode = await _toolsRepo.generateNextToolCode(
        companyId: companyId,
      );

      final isDuplicatedToolCode = await _toolsRepo.toolCodeExists(
        companyId: companyId,
        toolCode: toolCode,
      );

      if (isDuplicatedToolCode) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: 'Tool code already exists',
          ),
        );
        return false;
      }

      final toolToInsert = tool.copyWith(
        companyId: companyId,
        toolCode: toolCode,
        toolName: cleanToolName,
        createdByProfileId: createdByProfileId,
        status: 'active',
      );

      final addedTool = await _toolsRepo.addTool(tool: toolToInsert);

      emitUpdatedTools([...state.tools, addedTool], isSubmitting: false);

      return true;
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
      return false;
    }
  }

  Future<bool> updateTool({
    required String currentToolCode,
    required ToolModel updatedTool,
    String? companyId,
  }) async {
    final existingTool = _findToolByCode(currentToolCode);
    final toolId = updatedTool.id ?? existingTool?.id;
    final cleanToolName = updatedTool.toolName.trim();

    if (companyId == null || companyId.isEmpty) {
      emit(state.copyWith(errorMessage: 'Company ID was not found'));
      return false;
    }

    if (toolId == null || toolId.isEmpty) {
      emit(state.copyWith(errorMessage: 'Tool ID was not found'));
      return false;
    }

    if (cleanToolName.isEmpty) {
      return false;
    }

    if (updatedTool.unitId == null || updatedTool.categoryId == null) {
      emit(state.copyWith(errorMessage: 'Unit and category are required'));
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      final isDuplicatedToolCode = await _toolsRepo.toolCodeExists(
        companyId: companyId,
        toolCode: updatedTool.toolCode,
        ignoredToolId: toolId,
      );

      if (isDuplicatedToolCode) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: 'Tool code already exists',
          ),
        );
        return false;
      }

      final isDuplicatedToolName = await _toolsRepo.toolNameExists(
        companyId: companyId,
        toolName: cleanToolName,
        ignoredToolId: toolId,
      );

      if (isDuplicatedToolName) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: 'Tool name already exists',
          ),
        );
        return false;
      }

      final toolToUpdate = updatedTool.copyWith(
        id: toolId,
        companyId: companyId,
        toolName: cleanToolName,
      );

      final savedTool = await _toolsRepo.updateTool(
        toolId: toolId,
        tool: toolToUpdate,
      );

      final updatedTools = state.tools.map((tool) {
        if (tool.id == toolId) {
          return savedTool;
        }

        return tool;
      }).toList();

      emitUpdatedTools(updatedTools, isSubmitting: false);

      return true;
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
      return false;
    }
  }

  Future<bool> deleteTool(ToolModel tool) async {
    final existingTool = tool.id == null
        ? _findToolByCode(tool.toolCode)
        : null;
    final toolId = tool.id ?? existingTool?.id;

    if (toolId == null || toolId.isEmpty) {
      emit(state.copyWith(errorMessage: 'Tool ID was not found'));
      return false;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));

    try {
      await _toolsRepo.deleteTool(toolId: toolId);

      final updatedTools = state.tools.where((item) {
        return item.id != toolId;
      }).toList();

      emitUpdatedTools(updatedTools, isSubmitting: false);

      return true;
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.toString()));
      return false;
    }
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

  void emitUpdatedTools(
    List<ToolModel> tools, {
    bool? isLoading,
    bool? isSubmitting,
  }) {
    emit(
      state.copyWith(
        tools: tools,
        filteredTools: filterTools(tools: tools, query: state.searchQuery),
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
