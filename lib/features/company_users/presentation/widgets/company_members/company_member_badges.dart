part of '../company_members_list.dart';

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final color = _roleColor(role);

    return _SoftBadge(
      text: CompanyRoles.label(role),
      icon: AppIcons.adminPanelSettingsOutlined,
      color: color,
    );
  }

  Color _roleColor(String? role) {
    switch (CompanyRoles.normalize(role)) {
      case CompanyRoles.owner:
        return AppColors.primary;
      case CompanyRoles.admin:
        return AppColors.accent;
      case CompanyRoles.warehouseManager:
        return AppColors.success;
      case CompanyRoles.warehouseUser:
        return AppColors.warning;
      case CompanyRoles.viewer:
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = status.trim().toLowerCase();

    final color = normalizedStatus == 'active'
        ? AppColors.success
        : normalizedStatus == 'inactive'
        ? AppColors.warning
        : AppColors.textSecondary;

    return _SoftBadge(
      text: _statusLabel(status),
      icon: normalizedStatus == 'active'
          ? AppIcons.approve
          : AppIcons.pauseCircleOutline,
      color: color,
    );
  }

  String _statusLabel(String value) {
    final cleanValue = value.trim();

    if (cleanValue.isEmpty) {
      return 'Unknown';
    }

    return cleanValue[0].toUpperCase() + cleanValue.substring(1).toLowerCase();
  }
}

class _SoftBadge extends StatelessWidget {
  const _SoftBadge({
    required this.text,
    this.icon,
    this.color = AppColors.accent,
  });

  final String text;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const Gap(5),
          ],
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
