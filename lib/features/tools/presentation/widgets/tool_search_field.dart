import 'package:flutter/material.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';
import 'package:mina_system/core/theme/app_icons.dart';

class ToolSearchField extends StatefulWidget {
  const ToolSearchField({
    super.key,
    required this.initialQuery,
    required this.onChanged,
  });

  final String initialQuery;
  final ValueChanged<String> onChanged;

  @override
  State<ToolSearchField> createState() => _ToolSearchFieldState();
}

class _ToolSearchFieldState extends State<ToolSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      hint: 'Search tools...',
      icon: const Icon(AppIcons.search),
      controller: _controller,
      onChanged: widget.onChanged,
    );
  }
}
