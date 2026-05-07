import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/widgets/searchable_selection_field.dart';
import 'package:mina_system/features/reports/data/models/report_filter_model.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';

class ToolReportFilter extends StatelessWidget {
  const ToolReportFilter({
    super.key,
    required this.filters,
    required this.onChanged,
  });

  final ReportFilterModel filters;
  final ValueChanged<ReportFilterModel> onChanged;

  @override
  Widget build(BuildContext context) {
    final tools = context.watch<ToolsCubit>().state.tools;

    return SearchableSelectionField<ToolModel>(
      hint: 'Select Tool',
      items: tools,
      selectedItem: filters.tool,
      itemLabelBuilder: (tool) {
        return '${tool.toolName} (${tool.toolCode})';
      },
      searchMatcher: (tool, query) {
        final toolCode = tool.toolCode.trim().toLowerCase();
        final toolName = tool.toolName.trim().toLowerCase();
        final unit = tool.unit.trim().toLowerCase();
        final category = tool.category.trim().toLowerCase();

        return toolCode.contains(query) ||
            toolName.contains(query) ||
            unit.contains(query) ||
            category.contains(query);
      },
      onItemSelected: (tool) {
        onChanged(filters.copyWith(tool: tool));
      },
    );
  }
}
