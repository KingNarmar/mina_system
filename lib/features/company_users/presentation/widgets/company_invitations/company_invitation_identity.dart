part of '../company_invitations_list.dart';

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
