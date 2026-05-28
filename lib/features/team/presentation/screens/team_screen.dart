import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_cubit.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_state.dart';
import 'package:mina_system/features/company_users/presentation/widgets/company_users_section.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/team/presentation/widgets/team_overview_panel.dart';
import 'package:mina_system/features/team/presentation/widgets/team_page_header.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRole = context.currentUserRole;
    final canViewTeam = CompanyRolePermissions.canViewTeam(currentRole);
    final canManageTeam = CompanyRolePermissions.canManageTeam(currentRole);
    final canInviteUsers = CompanyRolePermissions.canInviteUsers(currentRole);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        key: const PageStorageKey('team_screen_scroll_key'),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TeamPageHeader(
              currentRole: currentRole,
              canManageTeam: canManageTeam,
              canInviteUsers: canInviteUsers,
            ),
            const Gap(16),
            if (canViewTeam)
              BlocBuilder<CompanyUsersCubit, CompanyUsersState>(
                builder: (context, state) {
                  return TeamOverviewPanel(
                    totalMembers: state.members.length,
                    activeMembers: _countMembersByStatus(
                      state,
                      status: 'active',
                    ),
                    inactiveMembers: _countMembersByStatus(
                      state,
                      status: 'inactive',
                    ),
                    pendingInvitations: state.pendingCompanyInvitations.length,
                    recentActivityCount:
                        state.companyUserLifecycleAuditLogs.length,
                    isLoading: state.isLoading,
                  );
                },
              )
            else
              const _NoTeamPermissionView(),
            const Gap(18),
            if (canViewTeam) const CompanyUsersSection(),
          ],
        ),
      ),
    );
  }

  int _countMembersByStatus(CompanyUsersState state, {required String status}) {
    final normalizedStatus = status.trim().toLowerCase();

    return state.members.where((member) {
      return member.status.trim().toLowerCase() == normalizedStatus;
    }).length;
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
        borderRadius: BorderRadius.circular(18),
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
