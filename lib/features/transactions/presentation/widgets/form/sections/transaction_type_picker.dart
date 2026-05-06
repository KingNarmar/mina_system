import 'package:flutter/material.dart';
import 'package:mina_system/core/widgets/custom_dropdown_form_field.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_form_validators.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_type_helpers.dart';

class TransactionTypePicker extends StatelessWidget {
  const TransactionTypePicker({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  final String? selectedType;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return CustomDropdownFormField(
      hint: 'Transaction Type',
      value: selectedType,
      items: transactionTypeLabels,
      validator: validateRequiredTransactionDropdown,
      onChanged: onChanged,
    );
  }
}
