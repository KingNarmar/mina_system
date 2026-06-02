import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/theme/app_icons.dart';

class TeamPageHeader extends StatelessWidget {
  const TeamPageHeader({
    super.key,
    required this.currentRole,
    required this.canManageTeam,
    required this.canInviteUsers,
  });

  final String? currentRole;
  final bool canManageTeam;
  final bool canInviteUsers;

  @override
  Widget build(BuildContext context) {
    final roleLabel = CompanyRoles.label(currentRole);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlayDark.withValues(alpha: 0.035),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 760;

          final titleBlock = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.12),
                  ),
                ),
                child: const Icon(
                  AppIcons.groups2Outlined,
                  color: AppColors.accent,
                  size: 28,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Team Management',
                      style: AppTextStyles.heading.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      'Manage members, invitations, access roles, and trusted '
                      'team activity from one organized workspace.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final contextChips = Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: isCompact ? WrapAlignment.start : WrapAlignment.end,
            children: [
              _HeaderChip(
                icon: AppIcons.verifiedUser,
                label: 'Current role',
                value: roleLabel,
              ),
              _HeaderChip(
                icon: AppIcons.lookups,
                label: 'Access mode',
                value: _accessLabel(),
              ),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [titleBlock, const Gap(18), contextChips],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: titleBlock),
              const Gap(24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: contextChips,
              ),
            ],
          );
        },
      ),
    );
  }

  String _accessLabel() {
    if (canManageTeam && canInviteUsers) {
      return 'Full management';
    }

    if (canManageTeam) {
      return 'Lifecycle control';
    }

    return 'View only';
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 168),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.accent, size: 20),
          const Gap(10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Gap(2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
