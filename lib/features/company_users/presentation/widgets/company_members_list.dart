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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Members', style: AppTextStyles.title),
        const Gap(12),
        if (members.isEmpty)
          const Text('No company members found.', style: AppTextStyles.body)
        else
          Column(
            children: members.map((member) {
              final isCurrentUser = member.profileId == currentProfileId;
              final canManageTargetRole =
                  CompanyRolePermissions.canManageTargetRole(
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
                canChangeRole: canChangeRole,
                canDeactivate: canDeactivate,
                canReactivate: canReactivate,
                isChangeRoleSubmitting: isChangeRoleSubmitting,
                isDeactivateSubmitting: isDeactivateSubmitting,
                isReactivateSubmitting: isReactivateSubmitting,
                onChangeRolePressed: () => onChangeRolePressed(member),
                onDeactivatePressed: () => onDeactivatePressed(member),
                onReactivatePressed: () => onReactivatePressed(member),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class CompanyMemberRow extends StatelessWidget {
  const CompanyMemberRow({
    super.key,
    required this.member,
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

  final CompanyMemberModel member;
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
    final displayName = companyMemberDisplayName(member);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(Icons.person_outline, color: AppColors.textSecondary),
          SizedBox(
            width: 220,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName, style: AppTextStyles.body),
                if (member.email != null) ...[
                  const Gap(4),
                  Text(member.email!, style: AppTextStyles.caption),
                ],
              ],
            ),
          ),
          CompanyUserStatusBadge(text: CompanyRoles.label(member.role)),
          CompanyUserStatusBadge(text: member.status),
          if (canChangeRole)
            SizedBox(
              width: 150,
              child: MainButton(
                text: 'Change Role',
                isLoading: isChangeRoleSubmitting,
                onPressed: onChangeRolePressed,
              ),
            ),
          if (canDeactivate)
            SizedBox(
              width: 130,
              child: MainButton(
                text: 'Deactivate',
                color: AppColors.warning,
                isLoading: isDeactivateSubmitting,
                onPressed: onDeactivatePressed,
              ),
            ),
          if (canReactivate)
            SizedBox(
              width: 130,
              child: MainButton(
                text: 'Reactivate',
                color: AppColors.success,
                isLoading: isReactivateSubmitting,
                onPressed: onReactivatePressed,
              ),
            ),
        ],
      ),
    );
  }
}
