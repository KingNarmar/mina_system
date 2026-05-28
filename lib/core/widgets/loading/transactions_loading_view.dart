import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/widgets/loading/app_skeleton.dart';

class TransactionsLoadingView extends StatelessWidget {
  const TransactionsLoadingView({super.key, required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return AppSkeletonShimmer(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            const _TransactionsTabsSkeleton(),
            Expanded(
              child: isMobile
                  ? const _TransactionsMobileLoadingView()
                  : const _TransactionsDesktopLoadingView(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionsTabsSkeleton extends StatelessWidget {
  const _TransactionsTabsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.card,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: const SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            AppSkeletonBox(width: 112, height: 34, borderRadius: 999),
            Gap(10),
            AppSkeletonBox(width: 142, height: 34, borderRadius: 999),
            Gap(10),
            AppSkeletonBox(width: 126, height: 34, borderRadius: 999),
            Gap(10),
            AppSkeletonBox(width: 112, height: 34, borderRadius: 999),
          ],
        ),
      ),
    );
  }
}

class _TransactionsDesktopLoadingView extends StatelessWidget {
  const _TransactionsDesktopLoadingView();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TransactionsDesktopToolbarSkeleton(),
          Gap(12),
          _TransactionsFilterSkeleton(),
          Gap(16),
          _TransactionsTableSkeleton(),
        ],
      ),
    );
  }
}

class _TransactionsMobileLoadingView extends StatelessWidget {
  const _TransactionsMobileLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      itemCount: 8,
      separatorBuilder: (context, index) => const Gap(12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeletonBox(height: 52, borderRadius: 14),
              Gap(12),
              _TransactionsFilterSkeleton(),
            ],
          );
        }

        return const _TransactionCardSkeleton();
      },
    );
  }
}

class _TransactionsDesktopToolbarSkeleton extends StatelessWidget {
  const _TransactionsDesktopToolbarSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: AppSkeletonBox(height: 52, borderRadius: 14)),
        Gap(16),
        AppSkeletonBox(width: 164, height: 52, borderRadius: 14),
      ],
    );
  }
}

class _TransactionsFilterSkeleton extends StatelessWidget {
  const _TransactionsFilterSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          AppSkeletonBox(width: 58, height: 36, borderRadius: 999),
          Gap(8),
          AppSkeletonBox(width: 72, height: 36, borderRadius: 999),
          Gap(8),
          AppSkeletonBox(width: 82, height: 36, borderRadius: 999),
          Gap(8),
          AppSkeletonBox(width: 70, height: 36, borderRadius: 999),
          Gap(8),
          AppSkeletonBox(width: 92, height: 36, borderRadius: 999),
        ],
      ),
    );
  }
}

class _TransactionsTableSkeleton extends StatelessWidget {
  const _TransactionsTableSkeleton();

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
          const _TransactionsTableHeaderSkeleton(),
          const Gap(14),
          ...List.generate(
            7,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: _TransactionsTableRowSkeleton(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionsTableHeaderSkeleton extends StatelessWidget {
  const _TransactionsTableHeaderSkeleton();

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
        Expanded(child: AppSkeletonLine(height: 12)),
        Gap(12),
        AppSkeletonBox(width: 92, height: 12, borderRadius: 999),
      ],
    );
  }
}

class _TransactionsTableRowSkeleton extends StatelessWidget {
  const _TransactionsTableRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
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
          Expanded(child: AppSkeletonLine(height: 12)),
          Gap(12),
          AppSkeletonBox(width: 92, height: 32, borderRadius: 999),
        ],
      ),
    );
  }
}

class _TransactionCardSkeleton extends StatelessWidget {
  const _TransactionCardSkeleton();

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
                AppSkeletonLine(width: 210, height: 11),
                Gap(8),
                AppSkeletonLine(width: 150, height: 10),
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
