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
    this.companyTimezone,
  });

  final List<CompanyInvitationModel> invitations;
  final bool canCancelInvitations;
  final bool Function(String actionKey) isActionSubmitting;
  final ValueChanged<String> onCancelPressed;
  final String? companyTimezone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Invitations', style: AppTextStyles.title),
        const Gap(12),
        if (invitations.isEmpty)
          const Text('No company invitations found.', style: AppTextStyles.body)
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
                companyTimezone: companyTimezone,
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
    this.companyTimezone,
  });

  final CompanyInvitationModel invitation;
  final bool canCancelInvitations;
  final bool isCancelSubmitting;
  final ValueChanged<String> onCancelPressed;
  final String? companyTimezone;

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = invitation.status.trim().toLowerCase();
    final isPendingInvitation = normalizedStatus == 'pending';
    final canCancel = canCancelInvitations && isPendingInvitation;

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
            width: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invitation.email, style: AppTextStyles.body),
                const Gap(6),
                _InvitationAccountabilityLines(
                  invitation: invitation,
                  companyTimezone: companyTimezone,
                ),
              ],
            ),
          ),
          CompanyUserStatusBadge(text: CompanyRoles.label(invitation.role)),
          CompanyUserStatusBadge(text: invitation.status),
          if (canCancel)
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

class _InvitationAccountabilityLines extends StatelessWidget {
  const _InvitationAccountabilityLines({
    required this.invitation,
    required this.companyTimezone,
  });

  final CompanyInvitationModel invitation;
  final String? companyTimezone;

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = invitation.status.trim().toLowerCase();

    final hasAcceptedActor = _hasActorDisplayData(
      profileId: invitation.acceptedByProfileId,
      fullName: invitation.acceptedByName,
      email: invitation.acceptedByEmail,
    );

    final hasCancelledActor = _hasActorDisplayData(
      profileId: invitation.cancelledByProfileId,
      fullName: invitation.cancelledByName,
      email: invitation.cancelledByEmail,
    );

    final shouldShowAcceptedDetails =
        normalizedStatus == 'accepted' ||
        invitation.acceptedAt != null ||
        hasAcceptedActor;

    final shouldShowCancelledDetails =
        normalizedStatus == 'cancelled' ||
        invitation.cancelledAt != null ||
        hasCancelledActor;

    final expiryLabel = normalizedStatus == 'expired'
        ? 'Expired at'
        : 'Expires at';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InvitationAccountabilityLine(
          label: 'Invited by',
          value: companyUserActorDisplayName(
            fullName: invitation.invitedByName,
            email: invitation.invitedByEmail,
            fallback: 'Unknown inviter',
          ),
        ),
        _InvitationAccountabilityLine(
          label: 'Invited at',
          value: formatInvitationDate(
            invitation.createdAt,
            timezone: companyTimezone,
          ),
        ),
        _InvitationAccountabilityLine(
          label: expiryLabel,
          value: formatInvitationDate(
            invitation.expiresAt,
            timezone: companyTimezone,
          ),
        ),
        if (shouldShowAcceptedDetails) ...[
          _InvitationAccountabilityLine(
            label: 'Accepted at',
            value: formatOptionalInvitationDate(
              invitation.acceptedAt,
              timezone: companyTimezone,
            ),
          ),
          if (hasAcceptedActor)
            _InvitationAccountabilityLine(
              label: 'Accepted by',
              value: companyUserActorDisplayName(
                fullName: invitation.acceptedByName,
                email: invitation.acceptedByEmail,
              ),
            ),
        ],
        if (shouldShowCancelledDetails) ...[
          _InvitationAccountabilityLine(
            label: 'Cancelled at',
            value: formatOptionalInvitationDate(
              invitation.cancelledAt,
              timezone: companyTimezone,
            ),
          ),
          if (hasCancelledActor)
            _InvitationAccountabilityLine(
              label: 'Cancelled by',
              value: companyUserActorDisplayName(
                fullName: invitation.cancelledByName,
                email: invitation.cancelledByEmail,
              ),
            ),
        ],
      ],
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

class _InvitationAccountabilityLine extends StatelessWidget {
  const _InvitationAccountabilityLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.caption,
          children: [
            TextSpan(
              text: '$label: ',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
