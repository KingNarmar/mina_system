import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/company_users/data/models/company_member_model.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_state.dart';
import 'package:mina_system/features/company_users/presentation/functions/company_users_helpers.dart';

class CompanyMembersList extends StatelessWidget {
  const CompanyMembersList({
    super.key,
    required this.members,
    required this.actorRole,
    required this.currentProfileId,
    required this.canChangeMemberRoles,
    required this.canDeactivateMembers,
    required this.canReactivateMembers,
    required this.isActionSubmitting,
    required this.onChangeRolePressed,
    required this.onDeactivatePressed,
    required this.onReactivatePressed,
    this.companyTimezone,
  });

  final List<CompanyMemberModel> members;
  final String? actorRole;
  final String currentProfileId;
  final bool canChangeMemberRoles;
  final bool canDeactivateMembers;
  final bool canReactivateMembers;
  final bool Function(String actionKey) isActionSubmitting;
  final ValueChanged<CompanyMemberModel> onChangeRolePressed;
  final ValueChanged<CompanyMemberModel> onDeactivatePressed;
  final ValueChanged<CompanyMemberModel> onReactivatePressed;
  final String? companyTimezone;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const _MembersEmptyState();
    }

    return Column(
      children: members.map((member) {
        final isCurrentUser = member.profileId == currentProfileId;

        final canManageTargetRole = CompanyRolePermissions.canManageTargetRole(
          actorRole: actorRole,
          targetRole: member.role,
        );

        final normalizedStatus = member.status.trim().toLowerCase();
        final isActiveMember = normalizedStatus == 'active';
        final isInactiveMember = normalizedStatus == 'inactive';

        final canChangeRole =
            canChangeMemberRoles && !isCurrentUser && canManageTargetRole;

        final canDeactivate =
            canDeactivateMembers &&
            !isCurrentUser &&
            canManageTargetRole &&
            isActiveMember;

        final canReactivate =
            canReactivateMembers &&
            !isCurrentUser &&
            canManageTargetRole &&
            isInactiveMember;

        final isChangeRoleSubmitting = isActionSubmitting(
          CompanyUsersSubmissionKey.changeRole(member.id),
        );

        final isDeactivateSubmitting = isActionSubmitting(
          CompanyUsersSubmissionKey.deactivateMember(member.id),
        );

        final isReactivateSubmitting = isActionSubmitting(
          CompanyUsersSubmissionKey.reactivateMember(member.id),
        );

        return CompanyMemberRow(
          member: member,
          isCurrentUser: isCurrentUser,
          canChangeRole: canChangeRole,
          canDeactivate: canDeactivate,
          canReactivate: canReactivate,
          isChangeRoleSubmitting: isChangeRoleSubmitting,
          isDeactivateSubmitting: isDeactivateSubmitting,
          isReactivateSubmitting: isReactivateSubmitting,
          companyTimezone: companyTimezone,
          onChangeRolePressed: () => onChangeRolePressed(member),
          onDeactivatePressed: () => onDeactivatePressed(member),
          onReactivatePressed: () => onReactivatePressed(member),
        );
      }).toList(),
    );
  }
}

class CompanyMemberRow extends StatelessWidget {
  const CompanyMemberRow({
    super.key,
    required this.member,
    required this.isCurrentUser,
    required this.canChangeRole,
    required this.canDeactivate,
    required this.canReactivate,
    required this.isChangeRoleSubmitting,
    required this.isDeactivateSubmitting,
    required this.isReactivateSubmitting,
    required this.onChangeRolePressed,
    required this.onDeactivatePressed,
    required this.onReactivatePressed,
    this.companyTimezone,
  });

  final CompanyMemberModel member;
  final bool isCurrentUser;
  final bool canChangeRole;
  final bool canDeactivate;
  final bool canReactivate;
  final bool isChangeRoleSubmitting;
  final bool isDeactivateSubmitting;
  final bool isReactivateSubmitting;
  final VoidCallback onChangeRolePressed;
  final VoidCallback onDeactivatePressed;
  final VoidCallback onReactivatePressed;
  final String? companyTimezone;

  @override
  Widget build(BuildContext context) {
    final displayName = companyMemberDisplayName(member);
    final email = member.email?.trim();
    final hasEmail = email != null && email.isNotEmpty;

    final hasActions = canChangeRole || canDeactivate || canReactivate;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 720;

          final identity = _MemberIdentity(
            displayName: displayName,
            email: hasEmail ? email : null,
            role: member.role,
            status: member.status,
            isCurrentUser: isCurrentUser,
          );

          final details = _MemberAccountabilityPanel(
            member: member,
            companyTimezone: companyTimezone,
          );

          final actions = _MemberActions(
            hasActions: hasActions,
            canChangeRole: canChangeRole,
            canDeactivate: canDeactivate,
            canReactivate: canReactivate,
            isChangeRoleSubmitting: isChangeRoleSubmitting,
            isDeactivateSubmitting: isDeactivateSubmitting,
            isReactivateSubmitting: isReactivateSubmitting,
            onChangeRolePressed: onChangeRolePressed,
            onDeactivatePressed: onDeactivatePressed,
            onReactivatePressed: onReactivatePressed,
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                identity,
                const Gap(14),
                details,
                const Gap(14),
                actions,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: identity),
                  const Gap(18),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: actions,
                  ),
                ],
              ),
              const Gap(14),
              details,
            ],
          );
        },
      ),
    );
  }
}

class _MemberIdentity extends StatelessWidget {
  const _MemberIdentity({
    required this.displayName,
    required this.email,
    required this.role,
    required this.status,
    required this.isCurrentUser,
  });

  final String displayName;
  final String? email;
  final String role;
  final String status;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MemberAvatar(text: _initialsFor(displayName, email)),
        const Gap(14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    displayName,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (isCurrentUser) const _SoftBadge(text: 'You'),
                ],
              ),
              if (email != null) ...[
                const Gap(4),
                Text(
                  email!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const Gap(10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _RoleBadge(role: role),
                  _StatusBadge(status: status),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _initialsFor(String name, String? email) {
    final source = name.trim().isNotEmpty ? name.trim() : email?.trim() ?? '';

    if (source.isEmpty) {
      return '?';
    }

    final parts = source
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    final firstPart = parts.isNotEmpty ? parts.first : source;

    if (firstPart.length >= 2) {
      return firstPart.substring(0, 2).toUpperCase();
    }

    return firstPart[0].toUpperCase();
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.14)),
      ),
      child: Center(
        child: Text(
          text,
          style: AppTextStyles.body.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _MemberAccountabilityPanel extends StatelessWidget {
  const _MemberAccountabilityPanel({
    required this.member,
    required this.companyTimezone,
  });

  final CompanyMemberModel member;
  final String? companyTimezone;

  @override
  Widget build(BuildContext context) {
    final hasInviter = _hasActorDisplayData(
      profileId: member.invitedByProfileId,
      fullName: member.invitedByName,
      email: member.invitedByEmail,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        children: [
          _MemberMetaItem(
            icon: Icons.login_outlined,
            label: 'Joined',
            value: formatOptionalCompanyUserDate(
              member.joinedAt,
              timezone: companyTimezone,
            ),
          ),
          _MemberMetaItem(
            icon: Icons.add_circle_outline,
            label: 'Created',
            value: formatOptionalCompanyUserDate(
              member.createdAt,
              timezone: companyTimezone,
            ),
          ),
          _MemberMetaItem(
            icon: Icons.update_outlined,
            label: 'Updated',
            value: formatOptionalCompanyUserDate(
              member.updatedAt,
              timezone: companyTimezone,
            ),
          ),
          if (hasInviter)
            _MemberMetaItem(
              icon: Icons.person_add_alt_outlined,
              label: 'Invited by',
              value: companyUserActorDisplayName(
                fullName: member.invitedByName,
                email: member.invitedByEmail,
                fallback: 'Recorded inviter',
              ),
            ),
        ],
      ),
    );
  }

  bool _hasActorDisplayData({
    required String? profileId,
    required String? fullName,
    required String? email,
  }) {
    final hasProfileId = profileId != null && profileId.trim().isNotEmpty;
    final hasFullName = fullName != null && fullName.trim().isNotEmpty;
    final hasEmail = email != null && email.trim().isNotEmpty;

    return hasProfileId || hasFullName || hasEmail;
  }
}

class _MemberMetaItem extends StatelessWidget {
  const _MemberMetaItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 260),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.textSecondary),
          const Gap(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(2),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
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

class _MemberActions extends StatelessWidget {
  const _MemberActions({
    required this.hasActions,
    required this.canChangeRole,
    required this.canDeactivate,
    required this.canReactivate,
    required this.isChangeRoleSubmitting,
    required this.isDeactivateSubmitting,
    required this.isReactivateSubmitting,
    required this.onChangeRolePressed,
    required this.onDeactivatePressed,
    required this.onReactivatePressed,
  });

  final bool hasActions;
  final bool canChangeRole;
  final bool canDeactivate;
  final bool canReactivate;
  final bool isChangeRoleSubmitting;
  final bool isDeactivateSubmitting;
  final bool isReactivateSubmitting;
  final VoidCallback onChangeRolePressed;
  final VoidCallback onDeactivatePressed;
  final VoidCallback onReactivatePressed;

  @override
  Widget build(BuildContext context) {
    if (!hasActions) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            'No available actions',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        if (canChangeRole)
          SizedBox(
            width: 142,
            child: MainButton(
              text: 'Change Role',
              isLoading: isChangeRoleSubmitting,
              onPressed: onChangeRolePressed,
            ),
          ),
        if (canDeactivate)
          SizedBox(
            width: 124,
            child: MainButton(
              text: 'Deactivate',
              color: AppColors.warning,
              isLoading: isDeactivateSubmitting,
              onPressed: onDeactivatePressed,
            ),
          ),
        if (canReactivate)
          SizedBox(
            width: 124,
            child: MainButton(
              text: 'Reactivate',
              color: AppColors.success,
              isLoading: isReactivateSubmitting,
              onPressed: onReactivatePressed,
            ),
          ),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final color = _roleColor(role);

    return _SoftBadge(
      text: CompanyRoles.label(role),
      icon: Icons.admin_panel_settings_outlined,
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
          ? Icons.check_circle_outline
          : Icons.pause_circle_outline,
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

class _MembersEmptyState extends StatelessWidget {
  const _MembersEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.group_off_outlined,
              color: AppColors.accent,
              size: 28,
            ),
          ),
          const Gap(12),
          Text(
            'No members found',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(6),
          Text(
            'Company members will appear here after users join this workspace.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
