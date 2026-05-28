import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/company_users/data/models/company_invitation_model.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_state.dart';
import 'package:mina_system/features/company_users/presentation/functions/company_users_helpers.dart';

part 'company_invitations/company_invitation_row.dart';
part 'company_invitations/company_invitation_identity.dart';
part 'company_invitations/company_invitation_details.dart';
part 'company_invitations/company_invitation_actions.dart';
part 'company_invitations/company_invitation_badges.dart';

class CompanyInvitationsList extends StatelessWidget {
  const CompanyInvitationsList({
    super.key,
    required this.invitations,
    required this.canCancelInvitations,
    required this.isActionSubmitting,
    required this.onCancelPressed,
    this.companyTimezone,
  });

  final List<CompanyInvitationModel> invitations;
  final bool canCancelInvitations;
  final bool Function(String actionKey) isActionSubmitting;
  final ValueChanged<String> onCancelPressed;
  final String? companyTimezone;

  @override
  Widget build(BuildContext context) {
    if (invitations.isEmpty) {
      return const _InvitationsEmptyState();
    }

    return Column(
      children: invitations.map((invitation) {
        final isCancelSubmitting = isActionSubmitting(
          CompanyUsersSubmissionKey.cancelInvitation(invitation.id),
        );

        return CompanyInvitationRow(
          invitation: invitation,
          canCancelInvitations: canCancelInvitations,
          isCancelSubmitting: isCancelSubmitting,
          companyTimezone: companyTimezone,
          onCancelPressed: onCancelPressed,
        );
      }).toList(),
    );
  }
}

class _InvitationsEmptyState extends StatelessWidget {
  const _InvitationsEmptyState();

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
              Icons.mark_email_read_outlined,
              color: AppColors.accent,
              size: 28,
            ),
          ),
          const Gap(12),
          Text(
            'No invitations found',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(6),
          Text(
            'Invitations sent to new company users will appear here.',
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
