import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/company_users/data/models/company_invitation_model.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_state.dart';
import 'package:mina_system/features/company_users/presentation/functions/company_users_helpers.dart';

class CompanyInvitationsList extends StatelessWidget {
  const CompanyInvitationsList({
    super.key,
    required this.invitations,
    required this.canCancelInvitations,
    required this.isActionSubmitting,
    required this.onCancelPressed,
  });

  final List<CompanyInvitationModel> invitations;
  final bool canCancelInvitations;
  final bool Function(String actionKey) isActionSubmitting;
  final ValueChanged<String> onCancelPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pending Invitations', style: AppTextStyles.title),
        const Gap(12),
        if (invitations.isEmpty)
          const Text('No pending invitations.', style: AppTextStyles.body)
        else
          Column(
            children: invitations.map((invitation) {
              final isCancelSubmitting = isActionSubmitting(
                CompanyUsersSubmissionKey.cancelInvitation(invitation.id),
              );

              return CompanyInvitationRow(
                invitation: invitation,
                canCancelInvitations: canCancelInvitations,
                isCancelSubmitting: isCancelSubmitting,
                onCancelPressed: onCancelPressed,
              );
            }).toList(),
          ),
      ],
    );
  }
}

class CompanyInvitationRow extends StatelessWidget {
  const CompanyInvitationRow({
    super.key,
    required this.invitation,
    required this.canCancelInvitations,
    required this.isCancelSubmitting,
    required this.onCancelPressed,
  });

  final CompanyInvitationModel invitation;
  final bool canCancelInvitations;
  final bool isCancelSubmitting;
  final ValueChanged<String> onCancelPressed;

  @override
  Widget build(BuildContext context) {
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
          const Icon(Icons.mail_outline, color: AppColors.textSecondary),
          SizedBox(
            width: 240,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invitation.email, style: AppTextStyles.body),
                const Gap(4),
                Text(
                  'Expires: ${formatInvitationDate(invitation.expiresAt)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          CompanyUserStatusBadge(text: CompanyRoles.label(invitation.role)),
          CompanyUserStatusBadge(text: invitation.status),
          if (canCancelInvitations)
            SizedBox(
              width: 130,
              child: MainButton(
                text: 'Cancel',
                color: AppColors.warning,
                isLoading: isCancelSubmitting,
                onPressed: () => onCancelPressed(invitation.id),
              ),
            ),
        ],
      ),
    );
  }
}
