import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/company_users/data/models/company_member_model.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_state.dart';
import 'package:mina_system/features/company_users/presentation/functions/company_users_helpers.dart';
import 'package:mina_system/core/theme/app_icons.dart';

part 'company_members/company_member_row.dart';
part 'company_members/company_member_identity.dart';
part 'company_members/company_member_accountability.dart';
part 'company_members/company_member_actions.dart';
part 'company_members/company_member_badges.dart';

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
              AppIcons.groupOffOutlined,
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
