import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/routes/routes.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_icons.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_cubit.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key, required this.title});

  final String title;

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();

    if (!context.mounted) return;

    context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Flexible(
            child: Text(
              title,
              style: AppTextStyles.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Gap(16),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: BlocBuilder<CurrentContextCubit, CurrentContextState>(
                builder: (context, state) {
                  return _TopBarContextInfo(
                    state: state,
                    onSwitchCompany: () {
                      context
                          .read<CurrentContextCubit>()
                          .openCompanySelection();
                    },
                  );
                },
              ),
            ),
          ),
          const Gap(12),
          IconButton(
            tooltip: 'Logout',
            onPressed: () => _logout(context),
            icon: const Icon(AppIcons.logout),
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _TopBarContextInfo extends StatelessWidget {
  const _TopBarContextInfo({
    required this.state,
    required this.onSwitchCompany,
  });

  final CurrentContextState state;
  final VoidCallback onSwitchCompany;

  @override
  Widget build(BuildContext context) {
    if (state is CurrentContextLoading) {
      return const _TopBarStatus(text: 'Loading company...');
    }

    if (state is CurrentContextFailure) {
      return const _TopBarStatus(text: 'Company unavailable');
    }

    if (state is! CurrentContextLoaded) {
      return const _TopBarStatus(text: 'M.I.N.A System');
    }

    final loadedState = state as CurrentContextLoaded;
    final profile = loadedState.profile;
    final currentCompany = loadedState.currentCompany;

    final userName = profile.fullName?.trim();
    final userEmail = profile.email?.trim();

    final userLabel = userName != null && userName.isNotEmpty
        ? userName
        : userEmail != null && userEmail.isNotEmpty
        ? userEmail
        : 'Signed in user';

    if (currentCompany == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _UserAvatar(label: userLabel),
          const Gap(10),
          Flexible(
            child: Text(
              loadedState.hasMultipleCompanies
                  ? 'Select Company'
                  : 'No Company',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    final roleLabel = CompanyRoles.label(currentCompany.role);

    return LayoutBuilder(
      builder: (context, constraints) {
        final showSwitchCompanyButton =
            loadedState.hasMultipleCompanies && constraints.maxWidth >= 420;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _UserAvatar(label: userLabel),
            const Gap(10),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    userLabel,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(2),
                  Text(
                    '${currentCompany.name} • $roleLabel',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (showSwitchCompanyButton) ...[
              const Gap(10),
              TextButton.icon(
                onPressed: onSwitchCompany,
                icon: const Icon(AppIcons.switchCompany, size: 18),
                label: const Text('Switch Company'),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _TopBarStatus extends StatelessWidget {
  const _TopBarStatus({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.border,
      foregroundColor: AppColors.textPrimary,
      child: Text(
        _initials(label),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
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
