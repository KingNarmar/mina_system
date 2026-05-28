import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/widgets/loading/app_skeleton.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_colors.dart';

class DashboardLoadingView extends StatelessWidget {
  const DashboardLoadingView({super.key, required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return AppSkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _DashboardOverviewSkeleton(),
          const Gap(18),
          if (isMobile)
            const Column(
              children: [
                _RecentTransactionsSkeleton(),
                Gap(16),
                _QuickActionsSkeleton(),
              ],
            )
          else
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: _RecentTransactionsSkeleton()),
                Gap(18),
                Expanded(flex: 4, child: _QuickActionsSkeleton()),
              ],
            ),
        ],
      ),
    );
  }
}

class _DashboardOverviewSkeleton extends StatelessWidget {
  const _DashboardOverviewSkeleton();

  @override
  Widget build(BuildContext context) {
    return _SkeletonContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              AppSkeletonBox(width: 42, height: 42, borderRadius: 14),
              Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeletonLine(width: 180, height: 16),
                    Gap(8),
                    AppSkeletonLine(width: 240, height: 11),
                  ],
                ),
              ),
              Gap(12),
              AppSkeletonBox(width: 52, height: 28, borderRadius: 999),
            ],
          ),
          const Gap(16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = _columnsForWidth(constraints.maxWidth);
              const spacing = 10.0;
              final tileWidth =
                  (constraints.maxWidth - (spacing * (columns - 1))) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: List.generate(
                  4,
                  (_) => SizedBox(
                    width: tileWidth,
                    child: const _MetricTileSkeleton(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
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

class _MetricTileSkeleton extends StatelessWidget {
  const _MetricTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          AppSkeletonBox(width: 36, height: 36, borderRadius: 13),
          Gap(10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonLine(width: 44, height: 18),
                Gap(8),
                AppSkeletonLine(width: 86, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentTransactionsSkeleton extends StatelessWidget {
  const _RecentTransactionsSkeleton();

  @override
  Widget build(BuildContext context) {
    return _SkeletonContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(child: AppSkeletonLine(height: 16)),
              Gap(16),
              AppSkeletonLine(width: 72, height: 12),
            ],
          ),
          const Gap(14),
          ...List.generate(
            4,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: _RecentTransactionTileSkeleton(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentTransactionTileSkeleton extends StatelessWidget {
  const _RecentTransactionTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          AppSkeletonBox(width: 42, height: 42, borderRadius: 14),
          Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonLine(height: 13),
                Gap(8),
                AppSkeletonLine(width: 180, height: 11),
                Gap(8),
                AppSkeletonLine(width: 140, height: 10),
              ],
            ),
          ),
          Gap(8),
          AppSkeletonCircle(size: 20),
        ],
      ),
    );
  }
}

class _QuickActionsSkeleton extends StatelessWidget {
  const _QuickActionsSkeleton();

  @override
  Widget build(BuildContext context) {
    return _SkeletonContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSkeletonLine(width: 140, height: 16),
          const Gap(14),
          ...List.generate(
            4,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: _QuickActionTileSkeleton(),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTileSkeleton extends StatelessWidget {
  const _QuickActionTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          AppSkeletonBox(width: 34, height: 34, borderRadius: 12),
          Gap(12),
          Expanded(child: AppSkeletonLine(height: 12)),
          Gap(10),
          AppSkeletonCircle(size: 18),
        ],
      ),
    );
  }
}

class _SkeletonContainer extends StatelessWidget {
  const _SkeletonContainer({
    required this.child,
    required this.padding,
    required this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlayDark.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
