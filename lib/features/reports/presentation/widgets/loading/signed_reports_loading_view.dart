import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/widgets/loading/app_skeleton.dart';

class SignedReportsLoadingView extends StatelessWidget {
  const SignedReportsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonShimmer(
      child: Column(
        children: List.generate(
          4,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: _SignedReportCardSkeleton(),
          ),
        ),
      ),
    );
  }
}

class _SignedReportCardSkeleton extends StatelessWidget {
  const _SignedReportCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 720;

          const details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeletonLine(width: 180, height: 16),
              Gap(8),
              AppSkeletonLine(width: 220, height: 12),
              Gap(14),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _InfoChipSkeleton(width: 120),
                  _InfoChipSkeleton(width: 80),
                  _InfoChipSkeleton(width: 110),
                  _InfoChipSkeleton(width: 150),
                  _InfoChipSkeleton(width: 90),
                ],
              ),
              Gap(12),
              AppSkeletonLine(width: 170, height: 11),
            ],
          );

          if (isCompact) {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                details,
                Gap(14),
                AppSkeletonBox(height: 42, borderRadius: 12),
              ],
            );
          }

          return const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: details),
              Gap(16),
              AppSkeletonBox(width: 112, height: 42, borderRadius: 12),
            ],
          );
        },
      ),
    );
  }
}

class _InfoChipSkeleton extends StatelessWidget {
  const _InfoChipSkeleton({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return AppSkeletonBox(width: width, height: 32, borderRadius: 999);
  }
}
