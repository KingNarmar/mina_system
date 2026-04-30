import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text(title, style: AppTextStyles.title),
          const Spacer(),
          const Text('Demo Company', style: AppTextStyles.body),
          const SizedBox(width: 16),
          const CircleAvatar(
            radius: 18,
            child: Icon(Icons.person_outline, size: 20),
          ),
        ],
      ),
    );
  }
}
