import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_icons.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';

class LookupListTile extends StatelessWidget {
  const LookupListTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.onViewAuditHistory,
    this.onDelete,
    this.onRestore,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onViewAuditHistory;
  final VoidCallback? onDelete;
  final VoidCallback? onRestore;

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
        trailing: _buildTrailingActions(),
      ),
    );
  }

  Widget? _buildTrailingActions() {
    final actions = <Widget>[
      if (onViewAuditHistory != null)
        IconButton(
          onPressed: onViewAuditHistory,
          icon: const Icon(AppIcons.auditHistory),
          color: AppColors.textSecondary,
          tooltip: 'View Audit History',
        ),
      if (onRestore != null)
        IconButton(
          onPressed: onRestore,
          icon: const Icon(AppIcons.restore),
          color: AppColors.accent,
          tooltip: 'Restore',
        )
      else if (onDelete != null)
        IconButton(
          onPressed: onDelete,
          icon: const Icon(AppIcons.deactivate),
          color: AppColors.error,
          tooltip: 'Deactivate',
        ),
    ];

    if (actions.isEmpty) {
      return null;
    }

    return Row(mainAxisSize: MainAxisSize.min, children: actions);
  }
}
