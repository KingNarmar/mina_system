import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/widgets/loading/app_skeleton.dart';

class WorkersLoadingView extends StatelessWidget {
  const WorkersLoadingView({super.key, required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return AppSkeletonShimmer(
      child: isMobile
          ? const _WorkersMobileLoadingView()
          : const _WorkersDesktopLoadingView(),
    );
  }
}

class _WorkersDesktopLoadingView extends StatelessWidget {
  const _WorkersDesktopLoadingView();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WorkersDesktopToolbarSkeleton(),
          Gap(12),
          _WorkersStatusFilterSkeleton(),
          Gap(16),
          _WorkersTableSkeleton(),
        ],
      ),
    );
  }
}

class _WorkersMobileLoadingView extends StatelessWidget {
  const _WorkersMobileLoadingView();

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
            return const _WorkersMobileSearchSkeleton();
          }

          if (index == 1) {
            return const _WorkersStatusFilterSkeleton();
          }

          return const _WorkerCardSkeleton();
        },
      ),
    );
  }
}

class _WorkersDesktopToolbarSkeleton extends StatelessWidget {
  const _WorkersDesktopToolbarSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: AppSkeletonBox(height: 52, borderRadius: 14)),
        Gap(16),
        AppSkeletonBox(width: 132, height: 52, borderRadius: 14),
      ],
    );
  }
}

class _WorkersMobileSearchSkeleton extends StatelessWidget {
  const _WorkersMobileSearchSkeleton();

  @override
  Widget build(BuildContext context) {
    return const AppSkeletonBox(height: 52, borderRadius: 14);
  }
}

class _WorkersStatusFilterSkeleton extends StatelessWidget {
  const _WorkersStatusFilterSkeleton();

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

class _WorkersTableSkeleton extends StatelessWidget {
  const _WorkersTableSkeleton();

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
          const _WorkersTableHeaderSkeleton(),
          const Gap(14),
          ...List.generate(
            7,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: _WorkersTableRowSkeleton(),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkersTableHeaderSkeleton extends StatelessWidget {
  const _WorkersTableHeaderSkeleton();

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

class _WorkersTableRowSkeleton extends StatelessWidget {
  const _WorkersTableRowSkeleton();

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

class _WorkerCardSkeleton extends StatelessWidget {
  const _WorkerCardSkeleton();

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
                AppSkeletonLine(width: 180, height: 11),
                Gap(8),
                AppSkeletonLine(width: 130, height: 10),
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
