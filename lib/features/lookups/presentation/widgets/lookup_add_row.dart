import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';
import 'package:mina_system/core/theme/app_icons.dart';

class LookupAddRow extends StatefulWidget {
  const LookupAddRow({
    super.key,
    required this.hint,
    required this.controller,
    required this.onAdd,
    this.isCompactInputMode = false,
    this.onFocusChanged,
  });

  final String hint;
  final TextEditingController controller;
  final VoidCallback onAdd;
  final bool isCompactInputMode;
  final ValueChanged<bool>? onFocusChanged;

  @override
  State<LookupAddRow> createState() => _LookupAddRowState();
}

class _LookupAddRowState extends State<LookupAddRow> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    if (_focusNode.hasFocus) {
      widget.onFocusChanged?.call(false);
    }

    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gap = widget.isCompactInputMode ? 8.0 : 12.0;

    return Row(
      children: [
        Expanded(
          child: CustomTextFormField(
            hint: widget.hint,
            controller: widget.controller,
            focusNode: _focusNode,
          ),
        ),
        Gap(gap),
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: widget.onAdd,
            icon: const Icon(AppIcons.add),
            label: const Text('Add'),
          ),
        ),
      ],
    );
  }

  void _handleFocusChanged() {
    widget.onFocusChanged?.call(_focusNode.hasFocus);
  }
}
