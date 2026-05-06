import 'package:flutter/material.dart';
import 'package:mina_system/core/widgets/searchable_selection_field.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_form_helpers.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_form_validators.dart';

class TransactionToolSelection extends StatelessWidget {
  const TransactionToolSelection({
    super.key,
    required this.tools,
    required this.selectedTool,
    required this.onSelected,
  });

  final List<ToolModel> tools;
  final ToolModel? selectedTool;
  final ValueChanged<ToolModel> onSelected;

  @override
  Widget build(BuildContext context) {
    return SearchableSelectionField<ToolModel>(
      hint: 'Search Tool by Code or Name',
      items: tools,
      selectedItem: selectedTool,
      itemLabelBuilder: buildToolOptionLabel,
      validator: validateRequiredTransactionSelection,
      searchMatcher: (tool, query) {
        final toolCode = tool.toolCode.trim().toLowerCase();
        final toolName = tool.toolName.trim().toLowerCase();
        final category = tool.category.trim().toLowerCase();

        return toolCode.contains(query) ||
            toolName.contains(query) ||
            category.contains(query);
      },
      onItemSelected: onSelected,
    );
  }
}
