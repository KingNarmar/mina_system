import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/loading/app_skeleton.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_cubit.dart';
import 'package:mina_system/core/theme/app_icons.dart';

class PendingInvitationsLoadingView extends StatelessWidget {
  const PendingInvitationsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSkeletonShimmer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSkeletonCircle(size: 52),
          Gap(18),
          AppSkeletonLine(width: 260, height: 24),
          Gap(10),
          AppSkeletonLine(width: 360, height: 14),
          Gap(6),
          AppSkeletonLine(width: 300, height: 14),
          Gap(24),
          _PendingInvitationSkeletonCard(),
          Gap(12),
          _PendingInvitationSkeletonCard(),
        ],
      ),
    );
  }
}

class PendingInvitationsErrorView extends StatelessWidget {
  const PendingInvitationsErrorView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(AppIcons.errorOutline, size: 48, color: AppColors.error),
        const Gap(16),
        const Text(
          'Unable to load invitations',
          style: AppTextStyles.title,
          textAlign: TextAlign.center,
        ),
        const Gap(8),
        Text(message, style: AppTextStyles.body, textAlign: TextAlign.center),
        const Gap(24),
        MainButton(
          text: 'Retry',
          onPressed: () {
            context
                .read<CompanyUsersCubit>()
                .loadCurrentUserPendingInvitations();
          },
        ),
      ],
    );
  }
}

class NoPendingInvitationsView extends StatelessWidget {
  const NoPendingInvitationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          AppIcons.businessOutlined,
          size: 48,
          color: AppColors.accent,
        ),
        const Gap(16),
        const Text(
          'No Pending Invitations',
          style: AppTextStyles.heading,
          textAlign: TextAlign.center,
        ),
        const Gap(8),
        const Text(
          'You do not have any pending company invitations.',
          style: AppTextStyles.body,
          textAlign: TextAlign.center,
        ),
        const Gap(24),
        MainButton(
          text: 'Refresh',
          onPressed: () {
            context
                .read<CompanyUsersCubit>()
                .loadCurrentUserPendingInvitations();
          },
        ),
      ],
    );
  }
}

class _PendingInvitationSkeletonCard extends StatelessWidget {
  const _PendingInvitationSkeletonCard();

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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeletonLine(width: 210, height: 18),
          Gap(12),
          AppSkeletonLine(width: double.infinity, height: 12),
          Gap(8),
          AppSkeletonLine(width: 260, height: 12),
          Gap(18),
          Row(
            children: [
              Expanded(child: AppSkeletonBox(height: 42, borderRadius: 10)),
              Gap(12),
              Expanded(child: AppSkeletonBox(height: 42, borderRadius: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
