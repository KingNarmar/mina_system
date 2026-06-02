part of '../company_invitations_list.dart';

class _InvitationDetailsPanel extends StatelessWidget {
  const _InvitationDetailsPanel({
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

    final expiryLabel = normalizedStatus == 'expired' ? 'Expired' : 'Expires';

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
          _InvitationMetaItem(
            icon: AppIcons.personAddAltOutlined,
            label: 'Invited by',
            value: companyUserActorDisplayName(
              fullName: invitation.invitedByName,
              email: invitation.invitedByEmail,
              fallback: 'Unknown inviter',
            ),
          ),
          _InvitationMetaItem(
            icon: AppIcons.eventAvailableOutlined,
            label: 'Invited',
            value: formatInvitationDate(
              invitation.createdAt,
              timezone: companyTimezone,
            ),
          ),
          _InvitationMetaItem(
            icon: AppIcons.eventBusyOutlined,
            label: expiryLabel,
            value: formatInvitationDate(
              invitation.expiresAt,
              timezone: companyTimezone,
            ),
          ),
          if (shouldShowAcceptedDetails) ...[
            _InvitationMetaItem(
              icon: AppIcons.approve,
              label: 'Accepted',
              value: formatOptionalInvitationDate(
                invitation.acceptedAt,
                timezone: companyTimezone,
              ),
            ),
            if (hasAcceptedActor)
              _InvitationMetaItem(
                icon: AppIcons.worker,
                label: 'Accepted by',
                value: companyUserActorDisplayName(
                  fullName: invitation.acceptedByName,
                  email: invitation.acceptedByEmail,
                ),
              ),
          ],
          if (shouldShowCancelledDetails) ...[
            _InvitationMetaItem(
              icon: AppIcons.reject,
              label: 'Cancelled',
              value: formatOptionalInvitationDate(
                invitation.cancelledAt,
                timezone: companyTimezone,
              ),
            ),
            if (hasCancelledActor)
              _InvitationMetaItem(
                icon: AppIcons.personOffOutlined,
                label: 'Cancelled by',
                value: companyUserActorDisplayName(
                  fullName: invitation.cancelledByName,
                  email: invitation.cancelledByEmail,
                ),
              ),
          ],
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

class _InvitationMetaItem extends StatelessWidget {
  const _InvitationMetaItem({
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
