import 'package:flutter/material.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';

class CustodyBalanceSearchField extends StatefulWidget {
  const CustodyBalanceSearchField({
    super.key,
    required this.onChanged,
    this.onFocusChanged,
  });

  final ValueChanged<String> onChanged;
  final ValueChanged<bool>? onFocusChanged;

  @override
  State<CustodyBalanceSearchField> createState() =>
      _CustodyBalanceSearchFieldState();
}

class _CustodyBalanceSearchFieldState extends State<CustodyBalanceSearchField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      hint: 'Search custody balances...',
      focusNode: _focusNode,
      icon: const Icon(Icons.search),
      onChanged: widget.onChanged,
    );
  }

  void _handleFocusChanged() {
    widget.onFocusChanged?.call(_focusNode.hasFocus);
  }
}
