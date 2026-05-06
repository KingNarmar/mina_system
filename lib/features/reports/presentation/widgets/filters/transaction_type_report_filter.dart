import 'package:flutter/material.dart';
import 'package:mina_system/core/widgets/custom_dropdown_form_field.dart';
import 'package:mina_system/features/reports/data/models/report_filter_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_type_helpers.dart';

class TransactionTypeReportFilter extends StatelessWidget {
  const TransactionTypeReportFilter({
    super.key,
    required this.filters,
    required this.onChanged,
  });

  final ReportFilterModel filters;
  final ValueChanged<ReportFilterModel> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedLabel = filters.transactionType == null
        ? 'All types'
        : getTransactionTypeLabel(filters.transactionType!);

    return CustomDropdownFormField(
      hint: 'Transaction Type',
      value: selectedLabel,
      items: const ['All types', ...transactionTypeLabels],
      onChanged: (value) {
        if (value == null || value == 'All types') {
          onChanged(filters.copyWith(clearTransactionType: true));
          return;
        }

        onChanged(
          filters.copyWith(transactionType: getTransactionTypeFromLabel(value)),
        );
      },
    );
  }
}
