import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';

class TeamOverviewPanel extends StatelessWidget {
  const TeamOverviewPanel({
    super.key,
    required this.totalMembers,
    required this.activeMembers,
    required this.inactiveMembers,
    required this.pendingInvitations,
    required this.recentActivityCount,
    required this.isLoading,
  });

  final int totalMembers;
  final int activeMembers;
  final int inactiveMembers;
  final int pendingInvitations;
  final int recentActivityCount;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final cardsPerRow = maxWidth >= 1120
            ? 5
            : maxWidth >= 860
            ? 3
            : maxWidth >= 560
            ? 2
            : 1;

        const spacing = 12.0;
        final cardWidth =
            (maxWidth - (spacing * (cardsPerRow - 1))) / cardsPerRow;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            _OverviewStatCard(
              width: cardWidth,
              icon: Icons.groups_outlined,
              label: 'Total members',
              value: _formatValue(totalMembers),
              isLoading: isLoading,
            ),
            _OverviewStatCard(
              width: cardWidth,
              icon: Icons.check_circle_outline,
              label: 'Active members',
              value: _formatValue(activeMembers),
              isLoading: isLoading,
              accentColor: AppColors.success,
            ),
            _OverviewStatCard(
              width: cardWidth,
              icon: Icons.pause_circle_outline,
              label: 'Inactive members',
              value: _formatValue(inactiveMembers),
              isLoading: isLoading,
              accentColor: AppColors.warning,
            ),
            _OverviewStatCard(
              width: cardWidth,
              icon: Icons.mark_email_unread_outlined,
              label: 'Pending invites',
              value: _formatValue(pendingInvitations),
              isLoading: isLoading,
              accentColor: AppColors.accent,
            ),
            _OverviewStatCard(
              width: cardWidth,
              icon: Icons.history_outlined,
              label: 'Recent activity',
              value: _formatValue(recentActivityCount),
              isLoading: isLoading,
            ),
          ],
        );
      },
    );
  }

  String _formatValue(int value) {
    if (isLoading) {
      return '—';
    }

    return value.toString();
  }
}

class _OverviewStatCard extends StatelessWidget {
  const _OverviewStatCard({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.isLoading,
    this.accentColor = AppColors.primary,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;
  final bool isLoading;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.overlayDark.withValues(alpha: 0.025),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Text(
                      value,
                      key: ValueKey(value),
                      style: AppTextStyles.title.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Gap(2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
