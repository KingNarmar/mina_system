import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';

class LookupStatusToggle extends StatelessWidget {
  const LookupStatusToggle({
    super.key,
    required this.showInactive,
    required this.onChanged,
  });

  final bool showInactive;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ChoiceChip(
            label: const Text('Active'),
            selected: !showInactive,
            selectedColor: AppColors.accent.withValues(alpha: 0.16),
            onSelected: (_) => onChanged(false),
          ),
          ChoiceChip(
            label: const Text('Inactive'),
            selected: showInactive,
            selectedColor: AppColors.accent.withValues(alpha: 0.16),
            onSelected: (_) => onChanged(true),
          ),
        ],
      ),
    );
  }
}
