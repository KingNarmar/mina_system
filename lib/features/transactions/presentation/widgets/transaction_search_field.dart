import 'package:flutter/material.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';
import 'package:mina_system/core/theme/app_icons.dart';

class TransactionSearchField extends StatefulWidget {
  const TransactionSearchField({
    super.key,
    required this.initialQuery,
    required this.onChanged,
    this.onFocusChanged,
  });

  final String initialQuery;
  final ValueChanged<String> onChanged;
  final ValueChanged<bool>? onFocusChanged;

  @override
  State<TransactionSearchField> createState() => _TransactionSearchFieldState();
}

class _TransactionSearchFieldState extends State<TransactionSearchField> {
  final _focusNode = FocusNode();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      hint: 'Search transactions...',
      focusNode: _focusNode,
      controller: _controller,
      icon: const Icon(AppIcons.search),
      onChanged: widget.onChanged,
    );
  }

  void _handleFocusChanged() {
    widget.onFocusChanged?.call(_focusNode.hasFocus);
  }
}
