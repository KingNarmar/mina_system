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

class _InvitationIdentity extends StatelessWidget {
  const _InvitationIdentity({required this.invitation});

  final CompanyInvitationModel invitation;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InvitationIcon(status: invitation.status),
        const Gap(14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                invitation.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Gap(10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _RoleBadge(role: invitation.role),
                  _StatusBadge(status: invitation.status),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InvitationIcon extends StatelessWidget {
  const _InvitationIcon({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Icon(_statusIcon(status), color: color, size: 24),
    );
  }

  Color _statusColor(String value) {
    switch (value.trim().toLowerCase()) {
      case 'pending':
        return AppColors.accent;
      case 'accepted':
        return AppColors.success;
      case 'cancelled':
        return AppColors.warning;
      case 'expired':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _statusIcon(String value) {
    switch (value.trim().toLowerCase()) {
      case 'pending':
        return Icons.mark_email_unread_outlined;
      case 'accepted':
        return Icons.mark_email_read_outlined;
      case 'cancelled':
        return Icons.cancel_schedule_send_outlined;
      case 'expired':
        return Icons.schedule_outlined;
      default:
        return Icons.mail_outline;
    }
  }
}

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
            icon: Icons.person_add_alt_outlined,
            label: 'Invited by',
            value: companyUserActorDisplayName(
              fullName: invitation.invitedByName,
              email: invitation.invitedByEmail,
              fallback: 'Unknown inviter',
            ),
          ),
          _InvitationMetaItem(
            icon: Icons.event_available_outlined,
            label: 'Invited',
            value: formatInvitationDate(
              invitation.createdAt,
              timezone: companyTimezone,
            ),
          ),
          _InvitationMetaItem(
            icon: Icons.event_busy_outlined,
            label: expiryLabel,
            value: formatInvitationDate(
              invitation.expiresAt,
              timezone: companyTimezone,
            ),
          ),
          if (shouldShowAcceptedDetails) ...[
            _InvitationMetaItem(
              icon: Icons.check_circle_outline,
              label: 'Accepted',
              value: formatOptionalInvitationDate(
                invitation.acceptedAt,
                timezone: companyTimezone,
              ),
            ),
            if (hasAcceptedActor)
              _InvitationMetaItem(
                icon: Icons.person_outline,
                label: 'Accepted by',
                value: companyUserActorDisplayName(
                  fullName: invitation.acceptedByName,
                  email: invitation.acceptedByEmail,
                ),
              ),
          ],
          if (shouldShowCancelledDetails) ...[
            _InvitationMetaItem(
              icon: Icons.cancel_outlined,
              label: 'Cancelled',
              value: formatOptionalInvitationDate(
                invitation.cancelledAt,
                timezone: companyTimezone,
              ),
            ),
            if (hasCancelledActor)
              _InvitationMetaItem(
                icon: Icons.person_off_outlined,
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

class _InvitationAction extends StatelessWidget {
  const _InvitationAction({
    required this.canCancel,
    required this.isCancelSubmitting,
    required this.onCancelPressed,
  });

  final bool canCancel;
  final bool isCancelSubmitting;
  final VoidCallback onCancelPressed;

  @override
  Widget build(BuildContext context) {
    if (!canCancel) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: MainButton(
        text: 'Cancel',
        color: AppColors.warning,
        isLoading: isCancelSubmitting,
        onPressed: onCancelPressed,
      ),
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

    final color = switch (normalizedStatus) {
      'pending' => AppColors.accent,
      'accepted' => AppColors.success,
      'cancelled' => AppColors.warning,
      'expired' => AppColors.textSecondary,
      _ => AppColors.textSecondary,
    };

    final icon = switch (normalizedStatus) {
      'pending' => Icons.schedule_send_outlined,
      'accepted' => Icons.check_circle_outline,
      'cancelled' => Icons.cancel_outlined,
      'expired' => Icons.schedule_outlined,
      _ => Icons.info_outline,
    };

    return _SoftBadge(text: _statusLabel(status), icon: icon, color: color);
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
