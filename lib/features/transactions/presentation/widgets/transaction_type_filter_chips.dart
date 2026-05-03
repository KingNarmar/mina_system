import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_state.dart';

class TransactionTypeFilterChips extends StatelessWidget {
  const TransactionTypeFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
  });

  final TransactionTypeFilter selectedFilter;
  final ValueChanged<TransactionTypeFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TransactionTypeFilter.values.map((filter) {
        final isSelected = selectedFilter == filter;

        return ChoiceChip(
          selected: isSelected,
          label: Text(
            _getLabel(filter),
            style: AppTextStyles.caption.copyWith(
              color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          selectedColor: AppColors.accent,
          backgroundColor: AppColors.border,
          onSelected: (_) {
            onChanged(filter);
          },
        );
      }).toList(),
    );
  }

  String _getLabel(TransactionTypeFilter filter) {
    switch (filter) {
      case TransactionTypeFilter.all:
        return 'All';
      case TransactionTypeFilter.issue:
        return 'Issue';
      case TransactionTypeFilter.returnTool:
        return 'Return';
      case TransactionTypeFilter.lost:
        return 'Lost';
      case TransactionTypeFilter.damaged:
        return 'Damaged';
    }
  }
}
