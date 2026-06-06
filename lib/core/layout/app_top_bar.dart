import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_icons.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/account/presentation/widgets/account_avatar.dart';
import 'package:mina_system/features/account/presentation/widgets/account_panel.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_cubit.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_state.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({super.key, required this.title});

  final String title;

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
                    onAccountPressed: () {
                      showAccountPanel(context);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBarContextInfo extends StatelessWidget {
  const _TopBarContextInfo({
    required this.state,
    required this.onAccountPressed,
  });

  final CurrentContextState state;
  final VoidCallback onAccountPressed;

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
      return _AccountTopBarButton(
        userLabel: userLabel,
        title: loadedState.hasMultipleCompanies
            ? 'Select Company'
            : 'No Company',
        subtitle: userEmail,
        onPressed: onAccountPressed,
      );
    }

    final roleLabel = CompanyRoles.label(currentCompany.role);

    return _AccountTopBarButton(
      userLabel: userLabel,
      title: userLabel,
      subtitle: '${currentCompany.name} • $roleLabel',
      onPressed: onAccountPressed,
    );
  }
}

class _AccountTopBarButton extends StatelessWidget {
  const _AccountTopBarButton({
    required this.userLabel,
    required this.title,
    required this.onPressed,
    this.subtitle,
  });

  final String userLabel;
  final String title;
  final String? subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AccountAvatar(
                label: userLabel,
                radius: 18,
                backgroundColor: AppColors.border,
                foregroundColor: AppColors.textPrimary,
              ),
              const Gap(10),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                      const Gap(2),
                      Text(
                        subtitle!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const Gap(6),
              const Icon(
                AppIcons.dropdown,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
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
