import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mina_system/core/app_mode/app_mode.dart';
import 'package:mina_system/core/app_mode/app_mode_scope.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/routes/routes.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_icons.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/account/presentation/widgets/account_action_tile.dart';
import 'package:mina_system/features/account/presentation/widgets/account_avatar.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_cubit.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

const String _privacyPolicyUrl =
    'https://kingnarmar.com/mina-system/privacy-policy';

const String _accountDeletionUrl =
    'https://kingnarmar.com/mina-system/account-deletion';

Future<void> showAccountPanel(BuildContext context) async {
  final currentContextCubit = context.read<CurrentContextCubit>();
  final appMode = AppModeScope.maybeOf(context) ?? AppMode.live;
  final screenWidth = MediaQuery.sizeOf(context).width;
  final useBottomSheet = screenWidth < 700;

  if (useBottomSheet) {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) {
        return AppModeScope(
          mode: appMode,
          child: BlocProvider.value(
            value: currentContextCubit,
            child: const AccountPanel(isBottomSheet: true),
          ),
        );
      },
    );

    return;
  }

  await showDialog<void>(
    context: context,
    builder: (_) {
      return AppModeScope(
        mode: appMode,
        child: BlocProvider.value(
          value: currentContextCubit,
          child: const Dialog(
            insetPadding: EdgeInsets.all(24),
            backgroundColor: AppColors.transparent,
            child: AccountPanel(),
          ),
        ),
      );
    },
  );
}

class AccountPanel extends StatelessWidget {
  const AccountPanel({super.key, this.isBottomSheet = false});

  final bool isBottomSheet;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Align(
      alignment: isBottomSheet ? Alignment.bottomCenter : Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          margin: EdgeInsets.only(bottom: isBottomSheet ? bottomInset : 0),
          padding: EdgeInsets.fromLTRB(20, 18, 20, isBottomSheet ? 24 : 20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(isBottomSheet ? 24 : 22),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.overlayDark.withValues(alpha: 0.10),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: BlocBuilder<CurrentContextCubit, CurrentContextState>(
              builder: (context, state) {
                if (state is CurrentContextLoading ||
                    state is CurrentContextInitial) {
                  return const _AccountPanelLoadingView();
                }

                if (state is CurrentContextFailure) {
                  return _AccountPanelFailureView(message: state.message);
                }

                if (state is! CurrentContextLoaded) {
                  return const _AccountPanelFailureView(
                    message: 'Account context is not available.',
                  );
                }

                return _AccountPanelContent(state: state);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountPanelContent extends StatelessWidget {
  const _AccountPanelContent({required this.state});

  final CurrentContextLoaded state;

  @override
  Widget build(BuildContext context) {
    final appMode = AppModeScope.maybeOf(context) ?? AppMode.live;
    final isDemo = appMode.isDemo;

    final profile = state.profile;
    final currentCompany = state.currentCompany;

    final cleanName = profile.fullName?.trim();
    final cleanEmail = profile.email?.trim();

    final displayName = cleanName != null && cleanName.isNotEmpty
        ? cleanName
        : cleanEmail != null && cleanEmail.isNotEmpty
        ? cleanEmail
        : 'Signed in user';

    final emailLabel = cleanEmail != null && cleanEmail.isNotEmpty
        ? cleanEmail
        : 'No email available';

    final companyLabel = currentCompany?.name.trim().isNotEmpty == true
        ? currentCompany!.name.trim()
        : 'No company selected';

    final currentRole = currentCompany?.role;

    final roleLabel = currentRole == null
        ? 'No company role'
        : CompanyRoles.label(currentRole);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AccountPanelHeader(
            displayName: displayName,
            email: emailLabel,
            companyName: companyLabel,
            roleLabel: roleLabel,
          ),
          const Gap(18),
          if (isDemo) ...[const _DemoModeNotice(), const Gap(14)],
          if (state.hasMultipleCompanies && !isDemo) ...[
            AccountActionTile(
              icon: AppIcons.switchCompany,
              title: 'Switch Company',
              subtitle: 'Change the active workspace for this session.',
              onTap: () => _switchCompany(context),
            ),
            const Gap(10),
          ],
          AccountActionTile(
            icon: AppIcons.publicRounded,
            title: 'Privacy Policy',
            subtitle: 'Open Mina System privacy policy.',
            onTap: () {
              _openExternalLink(
                context: context,
                url: _privacyPolicyUrl,
                failureMessage: 'Unable to open Privacy Policy.',
              );
            },
          ),
          if (!isDemo) ...[
            const Gap(10),
            AccountActionTile(
              icon: AppIcons.manageAccountsOutlined,
              title: 'Request Account Deletion',
              subtitle: 'Open the verified account deletion request page.',
              foregroundColor: AppColors.error,
              iconColor: AppColors.error,
              onTap: () => _confirmAccountDeletionRequest(context),
            ),
          ],
          const Gap(14),
          const Divider(height: 1, color: AppColors.border),
          const Gap(14),
          AccountActionTile(
            icon: isDemo ? AppIcons.logout : AppIcons.logout,
            title: isDemo ? 'Exit Demo' : 'Logout',
            subtitle: isDemo
                ? 'Return to the welcome screen.'
                : 'Sign out from this device.',
            onTap: isDemo ? () => _exitDemo(context) : () => _logout(context),
            trailingIcon: null,
          ),
        ],
      ),
    );
  }

  Future<void> _switchCompany(BuildContext context) async {
    final cubit = context.read<CurrentContextCubit>();

    Navigator.of(context).maybePop();

    cubit.openCompanySelection();
  }

  Future<void> _confirmAccountDeletionRequest(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            AppIcons.warningAmberOutlined,
            color: AppColors.warning,
            size: 36,
          ),
          title: const Text('Request account deletion?'),
          content: const Text(
            'This will open Mina System account deletion request page. '
            'Your request will be reviewed and verified before processing. '
            'Active account data may be deleted or anonymized, while historical '
            'company records may retain limited snapshots for audit, accountability, '
            'legal, or security reasons.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    await _openExternalLink(
      context: context,
      url: _accountDeletionUrl,
      failureMessage: 'Unable to open account deletion request page.',
    );
  }

  Future<void> _openExternalLink({
    required BuildContext context,
    required String url,
    required String failureMessage,
  }) async {
    final uri = Uri.parse(url);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        return;
      }

      if (!context.mounted) {
        return;
      }

      _showMessageDialog(
        context: context,
        title: 'Unable to open link',
        message: failureMessage,
        icon: AppIcons.error,
        iconColor: AppColors.error,
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      _showMessageDialog(
        context: context,
        title: 'Unable to open link',
        message: failureMessage,
        icon: AppIcons.error,
        iconColor: AppColors.error,
      );
    }
  }

  Future<void> _exitDemo(BuildContext context) async {
    final router = GoRouter.of(context);

    Navigator.of(context).maybePop();

    router.go(Routes.welcome);
  }

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();

    if (!context.mounted) {
      return;
    }

    context.go(Routes.login);
  }

  Future<void> _showMessageDialog({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(icon, color: iconColor, size: 36),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class _DemoModeNotice extends StatelessWidget {
  const _DemoModeNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(AppIcons.info, color: AppColors.warning, size: 22),
          const Gap(10),
          Expanded(
            child: Text(
              'Demo mode uses sample local workspace data only.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountPanelHeader extends StatelessWidget {
  const _AccountPanelHeader({
    required this.displayName,
    required this.email,
    required this.companyName,
    required this.roleLabel,
  });

  final String displayName;
  final String email;
  final String companyName;
  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AccountAvatar(
          label: displayName,
          radius: 38,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
        ),
        const Gap(12),
        Text(
          displayName,
          style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w800),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const Gap(4),
        Text(
          email,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const Gap(12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _AccountChip(icon: AppIcons.company, label: companyName),
            _AccountChip(
              icon: AppIcons.verifiedUser,
              label: roleLabel,
              color: AppColors.accent,
            ),
          ],
        ),
      ],
    );
  }
}

class _AccountChip extends StatelessWidget {
  const _AccountChip({
    required this.icon,
    required this.label,
    this.color = AppColors.textPrimary,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const Gap(6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountPanelLoadingView extends StatelessWidget {
  const _AccountPanelLoadingView();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 220,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _AccountPanelFailureView extends StatelessWidget {
  const _AccountPanelFailureView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(AppIcons.error, color: AppColors.error, size: 42),
          const Gap(12),
          const Text(
            'Account unavailable',
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
          const Gap(8),
          Text(message, style: AppTextStyles.body, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
