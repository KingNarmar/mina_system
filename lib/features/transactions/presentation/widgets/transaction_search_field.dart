import 'package:flutter/material.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';

class TransactionSearchField extends StatelessWidget {
  const TransactionSearchField({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      hint: 'Search transactions...',
      icon: const Icon(Icons.search),
      onChanged: onChanged,
    );
  }
}
