import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';

class MoreItemsNote extends StatelessWidget {
  const MoreItemsNote({super.key, required this.remainingCount});

  final int remainingCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '+$remainingCount more items will be included in the full report.',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
