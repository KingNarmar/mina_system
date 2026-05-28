part of '../company_invitations_list.dart';

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
          final isCompact = constraints.maxWidth < 620;

          final identity = _InvitationIdentity(invitation: invitation);

          final details = _InvitationDetailsPanel(
            invitation: invitation,
            companyTimezone: companyTimezone,
          );

          final action = _InvitationAction(
            canCancel: canCancel,
            isCancelSubmitting: isCancelSubmitting,
            onCancelPressed: () => onCancelPressed(invitation.id),
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                identity,
                const Gap(14),
                details,
                if (canCancel) ...[const Gap(14), action],
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
                  if (canCancel) ...[
                    const Gap(14),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 130),
                      child: action,
                    ),
                  ],
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
