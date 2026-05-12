import 'package:flutter/material.dart';
import 'package:mina_system/core/widgets/searchable_selection_field.dart';
import 'package:mina_system/features/reports/data/models/report_filter_model.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';

class ToolReportFilter extends StatelessWidget {
  const ToolReportFilter({
    super.key,
    required this.filters,
    required this.tools,
    required this.onChanged,
  });

  final ReportFilterModel filters;
  final List<ToolModel> tools;
  final ValueChanged<ReportFilterModel> onChanged;

  @override
  Widget build(BuildContext context) {
    return SearchableSelectionField<ToolModel>(
      hint: 'Select Tool',
      items: tools,
      selectedItem: filters.tool,
      itemLabelBuilder: (tool) {
        final statusSuffix = tool.status.trim().toLowerCase() == 'inactive'
            ? ' - Inactive'
            : '';

        return '${tool.toolName} (${tool.toolCode})$statusSuffix';
      },
      searchMatcher: (tool, query) {
        final toolCode = tool.toolCode.trim().toLowerCase();
        final toolName = tool.toolName.trim().toLowerCase();
        final unit = tool.unit.trim().toLowerCase();
        final category = tool.category.trim().toLowerCase();
        final status = tool.status.trim().toLowerCase();

        return toolCode.contains(query) ||
            toolName.contains(query) ||
            unit.contains(query) ||
            category.contains(query) ||
            status.contains(query);
      },
      onItemSelected: (tool) {
        onChanged(filters.copyWith(tool: tool));
      },
    );
  }
}
