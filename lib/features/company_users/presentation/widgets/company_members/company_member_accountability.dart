part of '../company_members_list.dart';

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
