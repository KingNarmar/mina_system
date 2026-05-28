import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/widgets/loading/app_skeleton.dart';

class ToolsLoadingView extends StatelessWidget {
  const ToolsLoadingView({super.key, required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return AppSkeletonShimmer(
      child: isMobile
          ? const _ToolsMobileLoadingView()
          : const _ToolsDesktopLoadingView(),
    );
  }
}

class _ToolsDesktopLoadingView extends StatelessWidget {
  const _ToolsDesktopLoadingView();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ToolsDesktopToolbarSkeleton(),
          Gap(12),
          _ToolsStatusFilterSkeleton(),
          Gap(16),
          _ToolsTableSkeleton(),
        ],
      ),
    );
  }
}

class _ToolsMobileLoadingView extends StatelessWidget {
  const _ToolsMobileLoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        itemCount: 8,
        separatorBuilder: (context, index) => const Gap(12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const _ToolsMobileSearchSkeleton();
          }

          if (index == 1) {
            return const _ToolsStatusFilterSkeleton();
          }

          return const _ToolCardSkeleton();
        },
      ),
    );
  }
}

class _ToolsDesktopToolbarSkeleton extends StatelessWidget {
  const _ToolsDesktopToolbarSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: AppSkeletonBox(height: 52, borderRadius: 14)),
        Gap(16),
        AppSkeletonBox(width: 120, height: 52, borderRadius: 14),
      ],
    );
  }
}

class _ToolsMobileSearchSkeleton extends StatelessWidget {
  const _ToolsMobileSearchSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppSkeletonBox(height: 52, borderRadius: 14);
  }
}

class _ToolsStatusFilterSkeleton extends StatelessWidget {
  const _ToolsStatusFilterSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        AppSkeletonBox(width: 76, height: 36, borderRadius: 999),
        Gap(8),
        AppSkeletonBox(width: 86, height: 36, borderRadius: 999),
      ],
    );
  }
}

class _ToolsTableSkeleton extends StatelessWidget {
  const _ToolsTableSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const _ToolsTableHeaderSkeleton(),
          const Gap(14),
          ...List.generate(
            7,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: _ToolsTableRowSkeleton(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolsTableHeaderSkeleton extends StatelessWidget {
  const _ToolsTableHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(flex: 2, child: AppSkeletonLine(height: 12)),
        Gap(12),
        Expanded(child: AppSkeletonLine(height: 12)),
        Gap(12),
        Expanded(child: AppSkeletonLine(height: 12)),
        Gap(12),
        Expanded(child: AppSkeletonLine(height: 12)),
        Gap(12),
        AppSkeletonBox(width: 96, height: 12, borderRadius: 999),
      ],
    );
  }
}

class _ToolsTableRowSkeleton extends StatelessWidget {
  const _ToolsTableRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Expanded(flex: 2, child: AppSkeletonLine(height: 13)),
          Gap(12),
          Expanded(child: AppSkeletonLine(height: 12)),
          Gap(12),
          Expanded(child: AppSkeletonLine(height: 12)),
          Gap(12),
          Expanded(child: AppSkeletonLine(height: 12)),
          Gap(12),
          AppSkeletonBox(width: 96, height: 32, borderRadius: 999),
        ],
      ),
    );
  }
}

class _ToolCardSkeleton extends StatelessWidget {
  const _ToolCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          AppSkeletonBox(width: 44, height: 44, borderRadius: 15),
          Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonLine(height: 14),
                Gap(8),
                AppSkeletonLine(width: 170, height: 11),
                Gap(8),
                AppSkeletonLine(width: 120, height: 10),
              ],
            ),
          ),
          Gap(12),
          AppSkeletonCircle(size: 28),
        ],
      ),
    );
  }
}
