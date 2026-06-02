import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mina_system/core/routes/routes.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_cubit.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_state.dart';
import 'package:mina_system/features/current_context/data/models/company_model.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_cubit.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/company_selection_list.dart';
import '../widgets/pending_company_invitations_section.dart';
import 'package:mina_system/core/theme/app_icons.dart';

class SelectCompanyScreen extends StatelessWidget {
  const SelectCompanyScreen({
    super.key,
    required this.companies,
    required this.onCompanySelected,
  });

  final List<CompanyModel> companies;
  final ValueChanged<String> onCompanySelected;

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();

    if (!context.mounted) {
      return;
    }

    context.go(Routes.emailEntry);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CompanyUsersCubit, CompanyUsersState>(
      listenWhen: (previous, current) {
        return previous.isSubmitting && !current.isSubmitting;
      },
      listener: (context, state) {
        if (state.hasError) {
          AppMessage.showError(context, state.errorMessage!);
          context.read<CompanyUsersCubit>().clearErrorMessage();
          return;
        }

        context.read<CurrentContextCubit>().loadCurrentContext(
          restoreLastSelectedCompany: false,
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          titleSpacing: 24,
          title: Text(
            'M.I.N.A System',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(AppIcons.logout, size: 18),
              label: const Text('Logout'),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: BlocBuilder<CompanyUsersCubit, CompanyUsersState>(
                  builder: (context, state) {
                    final pendingInvitations =
                        state.pendingCurrentUserInvitations;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _WorkspaceHeroCard(
                          activeCompaniesCount: companies.length,
                          pendingInvitationsCount: pendingInvitations.length,
                        ),
                        const Gap(20),
                        CompanySelectionList(
                          companies: companies,
                          onCompanySelected: onCompanySelected,
                        ),
                        if (pendingInvitations.isNotEmpty) ...[
                          const Gap(24),
                          PendingCompanyInvitationsSection(
                            invitations: pendingInvitations,
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkspaceHeroCard extends StatelessWidget {
  const _WorkspaceHeroCard({
    required this.activeCompaniesCount,
    required this.pendingInvitationsCount,
  });

  final int activeCompaniesCount;
  final int pendingInvitationsCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlayDark.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              right: -60,
              top: -70,
              child: _DecorativeCircle(
                size: 160,
                color: AppColors.accent.withValues(alpha: 0.12),
              ),
            ),
            Positioned(
              left: -45,
              bottom: -65,
              child: _DecorativeCircle(
                size: 140,
                color: AppColors.primary.withValues(alpha: 0.06),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          AppIcons.company,
                          color: AppColors.accent,
                          size: 30,
                        ),
                      ),
                      const Gap(14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Workspace Access',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              'Choose Workspace',
                              style: AppTextStyles.heading.copyWith(
                                fontSize: 26,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  Text(
                    'Select the company workspace you want to manage, or review pending invitations before entering the system.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Gap(18),
                  _SignedInUserContext(
                    activeCompaniesCount: activeCompaniesCount,
                    pendingInvitationsCount: pendingInvitationsCount,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignedInUserContext extends StatelessWidget {
  const _SignedInUserContext({
    required this.activeCompaniesCount,
    required this.pendingInvitationsCount,
  });

  final int activeCompaniesCount;
  final int pendingInvitationsCount;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentContextCubit, CurrentContextState>(
      builder: (context, state) {
        if (state is! CurrentContextLoaded) {
          return const SizedBox.shrink();
        }

        final fullName = state.profile.fullName?.trim();
        final email = state.profile.email?.trim();

        final userLabel = fullName != null && fullName.isNotEmpty
            ? fullName
            : email != null && email.isNotEmpty
            ? email
            : 'Signed in user';

        final shouldShowEmail =
            email != null && email.isNotEmpty && email != userLabel;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                child: Text(
                  _initials(userLabel),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userLabel,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (shouldShowEmail) ...[
                      const Gap(2),
                      Text(
                        email,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Gap(8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniInfoPill(
                          icon: AppIcons.businessCenterOutlined,
                          text: '$activeCompaniesCount workspaces',
                        ),
                        if (pendingInvitationsCount > 0)
                          _MiniInfoPill(
                            icon: AppIcons.markEmailUnreadOutlined,
                            text: '$pendingInvitationsCount invitations',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _initials(String value) {
    final cleanValue = value.trim();

    if (cleanValue.isEmpty) {
      return '?';
    }

    final parts = cleanValue
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts[1].substring(0, 1)}'
        .toUpperCase();
  }
}

class _MiniInfoPill extends StatelessWidget {
  const _MiniInfoPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accent),
          const Gap(6),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
