import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_cubit.dart';

class PendingInvitationsErrorView extends StatelessWidget {
  const PendingInvitationsErrorView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
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
        const Icon(Icons.business_outlined, size: 48, color: AppColors.accent),
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
