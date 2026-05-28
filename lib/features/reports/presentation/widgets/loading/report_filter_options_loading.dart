import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/widgets/loading/app_skeleton.dart';

class ReportFilterOptionsLoading extends StatelessWidget {
  const ReportFilterOptionsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonShimmer(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 720;

            if (isCompact) {
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ReportFilterHeaderSkeleton(),
                  Gap(16),
                  _ReportFilterFieldSkeleton(),
                  Gap(12),
                  _ReportFilterFieldSkeleton(),
                  Gap(12),
                  _ReportFilterFieldSkeleton(),
                ],
              );
            }

            return const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ReportFilterHeaderSkeleton(),
                Gap(16),
                Row(
                  children: [
                    Expanded(child: _ReportFilterFieldSkeleton()),
                    Gap(12),
                    Expanded(child: _ReportFilterFieldSkeleton()),
                    Gap(12),
                    Expanded(child: _ReportFilterFieldSkeleton()),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReportFilterHeaderSkeleton extends StatelessWidget {
  const _ReportFilterHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        AppSkeletonBox(width: 38, height: 38, borderRadius: 14),
        Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeletonLine(width: 170, height: 15),
              Gap(8),
              AppSkeletonLine(width: 280, height: 11),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReportFilterFieldSkeleton extends StatelessWidget {
  const _ReportFilterFieldSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppSkeletonLine(width: 86, height: 10),
          Gap(9),
          AppSkeletonLine(height: 13),
        ],
      ),
    );
  }
}
