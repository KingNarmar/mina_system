import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/widgets/loading/app_skeleton.dart';

class CompanySettingsLoadingView extends StatelessWidget {
  const CompanySettingsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideLayout = constraints.maxWidth >= 980;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isWideLayout ? 28 : 18),
            child: const AppSkeletonShimmer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CompanySettingsHeaderSkeleton(),
                  Gap(20),
                  _CompanySettingsSectionSelectorSkeleton(),
                  Gap(20),
                  _CompanySettingsContentSkeleton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CompanySettingsHeaderSkeleton extends StatelessWidget {
  const _CompanySettingsHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 760;

          final titleBlock = const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeletonBox(width: 52, height: 52, borderRadius: 16),
              Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeletonLine(width: 190, height: 18),
                    Gap(10),
                    AppSkeletonLine(height: 12),
                    Gap(8),
                    AppSkeletonLine(width: 320, height: 12),
                  ],
                ),
              ),
            ],
          );

          final infoChips = const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AppSkeletonBox(width: 130, height: 34, borderRadius: 999),
              AppSkeletonBox(width: 110, height: 34, borderRadius: 999),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [titleBlock, const Gap(16), infoChips],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: titleBlock),
              const Gap(18),
              Padding(padding: const EdgeInsets.only(top: 8), child: infoChips),
            ],
          );
        },
      ),
    );
  }
}

class _CompanySettingsSectionSelectorSkeleton extends StatelessWidget {
  const _CompanySettingsSectionSelectorSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            AppSkeletonBox(width: 160, height: 42, borderRadius: 12),
            Gap(6),
            AppSkeletonBox(width: 180, height: 42, borderRadius: 12),
            Gap(6),
            AppSkeletonBox(width: 170, height: 42, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}

class _CompanySettingsContentSkeleton extends StatelessWidget {
  const _CompanySettingsContentSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 820;

          if (isCompact) {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProfilePanelSkeleton(),
                Gap(16),
                _SettingsFormSkeleton(),
              ],
            );
          }

          return const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 4, child: _ProfilePanelSkeleton()),
              Gap(18),
              Expanded(flex: 7, child: _SettingsFormSkeleton()),
            ],
          );
        },
      ),
    );
  }
}

class _ProfilePanelSkeleton extends StatelessWidget {
  const _ProfilePanelSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeletonBox(width: 74, height: 74, borderRadius: 20),
          Gap(16),
          AppSkeletonLine(width: 190, height: 17),
          Gap(10),
          AppSkeletonLine(width: 240, height: 12),
          Gap(18),
          AppSkeletonBox(height: 44, borderRadius: 14),
          Gap(12),
          AppSkeletonBox(height: 44, borderRadius: 14),
          Gap(12),
          AppSkeletonBox(width: 150, height: 38, borderRadius: 12),
        ],
      ),
    );
  }
}

class _SettingsFormSkeleton extends StatelessWidget {
  const _SettingsFormSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeletonLine(width: 210, height: 17),
          Gap(8),
          AppSkeletonLine(width: 320, height: 12),
          Gap(18),
          _FormRowSkeleton(),
          Gap(12),
          _FormRowSkeleton(),
          Gap(12),
          _FormRowSkeleton(),
          Gap(18),
          AppSkeletonBox(width: 128, height: 44, borderRadius: 14),
        ],
      ),
    );
  }
}

class _FormRowSkeleton extends StatelessWidget {
  const _FormRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: AppSkeletonBox(height: 54, borderRadius: 14)),
        Gap(12),
        Expanded(child: AppSkeletonBox(height: 54, borderRadius: 14)),
      ],
    );
  }
}
