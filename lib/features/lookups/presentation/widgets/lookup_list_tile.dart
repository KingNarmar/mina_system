import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';

class LookupListTile extends StatelessWidget {
  const LookupListTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.onDelete,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          title,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle, style: AppTextStyles.caption),
        trailing: onDelete == null
            ? null
            : IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: AppColors.error,
                tooltip: 'Delete',
              ),
      ),
    );
  }
}
