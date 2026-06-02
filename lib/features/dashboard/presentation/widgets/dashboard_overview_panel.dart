import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/theme/app_icons.dart';

class DashboardOverviewPanel extends StatelessWidget {
  const DashboardOverviewPanel({
    super.key,
    required this.totalWorkers,
    required this.totalTools,
    required this.openCustodies,
    required this.closedToday,
  });

  final int totalWorkers;
  final int totalTools;
  final int openCustodies;
  final int closedToday;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlayDark.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -46,
              top: -56,
              child: _GlowCircle(
                size: 140,
                color: AppColors.accent.withValues(alpha: 0.08),
              ),
            ),
            Positioned(
              left: -38,
              bottom: -54,
              child: _GlowCircle(
                size: 120,
                color: AppColors.primary.withValues(alpha: 0.035),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _PanelHeader(),
                const Gap(16),
                _MetricsWrap(
                  totalWorkers: totalWorkers,
                  totalTools: totalTools,
                  openCustodies: openCustodies,
                  closedToday: closedToday,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            AppIcons.dashboardCustomizeOutlined,
            color: AppColors.accent,
            size: 22,
          ),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Operations Snapshot',
                style: AppTextStyles.title.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const Gap(3),
              Text(
                'Live summary of your workspace activity',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Gap(12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.16),
            ),
          ),
          child: Text(
            'Live',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricsWrap extends StatelessWidget {
  const _MetricsWrap({
    required this.totalWorkers,
    required this.totalTools,
    required this.openCustodies,
    required this.closedToday,
  });

  final int totalWorkers;
  final int totalTools;
  final int openCustodies;
  final int closedToday;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _columnsForWidth(constraints.maxWidth);
        const spacing = 10.0;
        final width =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: width,
              child: _MetricTile(
                label: 'Workers',
                value: totalWorkers.toString(),
                icon: AppIcons.team,
                color: AppColors.accent,
              ),
            ),
            SizedBox(
              width: width,
              child: _MetricTile(
                label: 'Tools',
                value: totalTools.toString(),
                icon: AppIcons.handymanOutlined,
                color: AppColors.success,
              ),
            ),
            SizedBox(
              width: width,
              child: _MetricTile(
                label: 'Open Custody',
                value: openCustodies.toString(),
                icon: AppIcons.inventory2Outlined,
                color: AppColors.warning,
              ),
            ),
            SizedBox(
              width: width,
              child: _MetricTile(
                label: 'Closed Today',
                value: closedToday.toString(),
                icon: AppIcons.done,
                color: AppColors.error,
              ),
            ),
          ],
        );
      },
    );
  }

  int _columnsForWidth(double width) {
    if (width < 280) {
      return 1;
    }

    if (width < AppBreakpoints.tablet) {
      return 2;
    }

    return 4;
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.065),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 21,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(6),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
