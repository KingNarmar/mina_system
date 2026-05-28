part of '../company_members_list.dart';

class _MemberIdentity extends StatelessWidget {
  const _MemberIdentity({
    required this.displayName,
    required this.email,
    required this.role,
    required this.status,
    required this.isCurrentUser,
  });

  final String displayName;
  final String? email;
  final String role;
  final String status;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MemberAvatar(text: _initialsFor(displayName, email)),
        const Gap(14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    displayName,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (isCurrentUser) const _SoftBadge(text: 'You'),
                ],
              ),
              if (email != null) ...[
                const Gap(4),
                Text(
                  email!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const Gap(10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _RoleBadge(role: role),
                  _StatusBadge(status: status),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _initialsFor(String name, String? email) {
    final source = name.trim().isNotEmpty ? name.trim() : email?.trim() ?? '';

    if (source.isEmpty) {
      return '?';
    }

    final parts = source
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    final firstPart = parts.isNotEmpty ? parts.first : source;

    if (firstPart.length >= 2) {
      return firstPart.substring(0, 2).toUpperCase();
    }

    return firstPart[0].toUpperCase();
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.14)),
      ),
      child: Center(
        child: Text(
          text,
          style: AppTextStyles.body.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
