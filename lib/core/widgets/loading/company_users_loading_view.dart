import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/widgets/loading/app_skeleton.dart';

class CompanyUsersLoadingView extends StatelessWidget {
  const CompanyUsersLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonShimmer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1040;

          final invitePanel = const _TeamSectionSkeleton(
            headerWidth: 130,
            subtitleWidth: 320,
            child: _InviteMemberSkeleton(),
          );

          const membersPanel = _TeamSectionSkeleton(
            headerWidth: 170,
            subtitleWidth: 420,
            trailingWidth: 34,
            child: _MembersDirectorySkeleton(),
          );

          const invitationsPanel = _TeamSectionSkeleton(
            headerWidth: 110,
            subtitleWidth: 360,
            trailingWidth: 34,
            child: _InvitationsSkeleton(),
          );

          const activityPanel = _TeamSectionSkeleton(
            headerWidth: 120,
            subtitleWidth: 420,
            trailingWidth: 34,
            child: _TeamActivitySkeleton(),
          );

          if (!isWide) {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TeamSectionSkeleton(
                  headerWidth: 130,
                  subtitleWidth: 320,
                  child: _InviteMemberSkeleton(),
                ),
                Gap(16),
                membersPanel,
                Gap(16),
                invitationsPanel,
                Gap(16),
                activityPanel,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              invitePanel,
              const Gap(18),
              membersPanel,
              const Gap(18),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: invitationsPanel),
                  Gap(18),
                  Expanded(flex: 7, child: activityPanel),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TeamSectionSkeleton extends StatelessWidget {
  const _TeamSectionSkeleton({
    required this.headerWidth,
    required this.subtitleWidth,
    required this.child,
    this.trailingWidth,
  });

  final double headerWidth;
  final double subtitleWidth;
  final double? trailingWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSkeletonBox(width: 42, height: 42, borderRadius: 15),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeletonLine(width: headerWidth, height: 16),
                    const Gap(8),
                    AppSkeletonLine(width: subtitleWidth, height: 11),
                  ],
                ),
              ),
              if (trailingWidth != null) ...[
                const Gap(12),
                AppSkeletonBox(
                  width: trailingWidth,
                  height: 34,
                  borderRadius: 999,
                ),
              ],
            ],
          ),
          const Gap(18),
          child,
        ],
      ),
    );
  }
}

class _InviteMemberSkeleton extends StatelessWidget {
  const _InviteMemberSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;

        if (isCompact) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSkeletonBox(height: 52, borderRadius: 14),
              Gap(12),
              AppSkeletonBox(height: 52, borderRadius: 14),
              Gap(12),
              AppSkeletonBox(height: 48, borderRadius: 14),
            ],
          );
        }

        return const Row(
          children: [
            Expanded(
              flex: 5,
              child: AppSkeletonBox(height: 52, borderRadius: 14),
            ),
            Gap(12),
            Expanded(
              flex: 3,
              child: AppSkeletonBox(height: 52, borderRadius: 14),
            ),
            Gap(12),
            AppSkeletonBox(width: 118, height: 48, borderRadius: 14),
          ],
        );
      },
    );
  }
}

class _MembersDirectorySkeleton extends StatelessWidget {
  const _MembersDirectorySkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _TeamListRowSkeleton(showBadge: true),
        Gap(10),
        _TeamListRowSkeleton(showBadge: true),
        Gap(10),
        _TeamListRowSkeleton(showBadge: true),
        Gap(10),
        _TeamListRowSkeleton(showBadge: true),
      ],
    );
  }
}

class _InvitationsSkeleton extends StatelessWidget {
  const _InvitationsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _TeamListRowSkeleton(showBadge: false),
        Gap(10),
        _TeamListRowSkeleton(showBadge: false),
        Gap(10),
        _TeamListRowSkeleton(showBadge: false),
      ],
    );
  }
}

class _TeamActivitySkeleton extends StatelessWidget {
  const _TeamActivitySkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _ActivityRowSkeleton(),
        Gap(10),
        _ActivityRowSkeleton(),
        Gap(10),
        _ActivityRowSkeleton(),
        Gap(10),
        _ActivityRowSkeleton(),
      ],
    );
  }
}

class _TeamListRowSkeleton extends StatelessWidget {
  const _TeamListRowSkeleton({required this.showBadge});

  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const AppSkeletonCircle(size: 40),
          const Gap(12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonLine(height: 13),
                Gap(8),
                AppSkeletonLine(width: 180, height: 11),
              ],
            ),
          ),
          if (showBadge) ...[
            const Gap(12),
            const AppSkeletonBox(width: 78, height: 30, borderRadius: 999),
          ],
          const Gap(10),
          const AppSkeletonCircle(size: 28),
        ],
      ),
    );
  }
}

class _ActivityRowSkeleton extends StatelessWidget {
  const _ActivityRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          AppSkeletonBox(width: 38, height: 38, borderRadius: 14),
          Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonLine(height: 13),
                Gap(8),
                AppSkeletonLine(width: 220, height: 11),
                Gap(8),
                AppSkeletonLine(width: 150, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
