import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_icons.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';

class CompanySettingsPanel extends StatelessWidget {
  const CompanySettingsPanel({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.child,
    this.badgeLabel,
    this.badgeIcon,
    this.headerActions,
    this.accountability,
    this.onViewAuditHistory,
    this.auditHistoryLabel = 'View Audit History',
    this.footer,
  });

  final String title;
  final String description;
  final IconData icon;
  final Widget child;
  final String? badgeLabel;
  final IconData? badgeIcon;
  final Widget? headerActions;
  final Widget? accountability;
  final VoidCallback? onViewAuditHistory;
  final String auditHistoryLabel;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlayDark.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CompanySettingsPanelHeader(
            title: title,
            description: description,
            icon: icon,
            badgeLabel: badgeLabel,
            badgeIcon: badgeIcon,
            headerActions: headerActions,
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                child,
                if (accountability != null) ...[const Gap(18), accountability!],
                if (onViewAuditHistory != null || footer != null) ...[
                  const Gap(16),
                  _CompanySettingsPanelActions(
                    onViewAuditHistory: onViewAuditHistory,
                    auditHistoryLabel: auditHistoryLabel,
                    footer: footer,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanySettingsPanelHeader extends StatelessWidget {
  const _CompanySettingsPanelHeader({
    required this.title,
    required this.description,
    required this.icon,
    required this.badgeLabel,
    required this.badgeIcon,
    required this.headerActions,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? badgeLabel;
  final IconData? badgeIcon;
  final Widget? headerActions;

  @override
  Widget build(BuildContext context) {
    final cleanBadgeLabel = badgeLabel?.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 720;

          final titleRow = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CompanySettingsPanelIcon(icon: icon),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const Gap(5),
                    Text(
                      description,
                      maxLines: isCompact ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final trailingItems = <Widget>[
            if (cleanBadgeLabel != null && cleanBadgeLabel.isNotEmpty)
              _CompanySettingsPanelBadge(
                label: cleanBadgeLabel,
                icon: badgeIcon,
              ),
            ?headerActions,
          ];

          if (trailingItems.isEmpty) {
            return titleRow;
          }

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleRow,
                const Gap(14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: trailingItems,
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: titleRow),
              const Gap(14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: trailingItems,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CompanySettingsPanelIcon extends StatelessWidget {
  const _CompanySettingsPanelIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.12)),
      ),
      child: Icon(icon, color: AppColors.accent, size: 20),
    );
  }
}

class _CompanySettingsPanelBadge extends StatelessWidget {
  const _CompanySettingsPanelBadge({required this.label, required this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon ?? AppIcons.verified, size: 14, color: AppColors.accent),
          const Gap(6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanySettingsPanelActions extends StatelessWidget {
  const _CompanySettingsPanelActions({
    required this.onViewAuditHistory,
    required this.auditHistoryLabel,
    required this.footer,
  });

  final VoidCallback? onViewAuditHistory;
  final String auditHistoryLabel;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (onViewAuditHistory != null)
            TextButton.icon(
              onPressed: onViewAuditHistory,
              icon: const Icon(AppIcons.auditHistory, size: 18),
              label: Text(auditHistoryLabel),
            ),
          ?footer,
        ],
      ),
    );
  }
}
