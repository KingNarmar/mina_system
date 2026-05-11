import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/company_users/presentation/widgets/company_users_section.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRole = context.currentUserRole;
    final canViewTeam = CompanyRolePermissions.canViewTeam(currentRole);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Team', style: AppTextStyles.heading),
            const Gap(8),
            const Text(
              'Manage company members, invitations, and team access.',
              style: AppTextStyles.body,
            ),
            const Gap(24),
            if (canViewTeam)
              const CompanyUsersSection()
            else
              const _NoTeamPermissionView(),
          ],
        ),
      ),
    );
  }
}

class _NoTeamPermissionView extends StatelessWidget {
  const _NoTeamPermissionView();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('No team access', style: AppTextStyles.title),
          Gap(8),
          Text(
            'Your current role does not have permission to view team management.',
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}
