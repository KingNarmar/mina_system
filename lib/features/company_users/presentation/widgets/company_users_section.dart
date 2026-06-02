import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/core/widgets/loading/company_users_loading_view.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_cubit.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_state.dart';
import 'package:mina_system/features/company_users/presentation/functions/company_users_dialogs.dart';
import 'package:mina_system/features/company_users/presentation/functions/company_users_helpers.dart';
import 'package:mina_system/features/company_users/presentation/widgets/company_invitations_list.dart';
import 'package:mina_system/features/company_users/presentation/widgets/company_members_list.dart';
import 'package:mina_system/features/company_users/presentation/widgets/company_user_lifecycle_audit_logs_list.dart';
import 'package:mina_system/features/company_users/presentation/widgets/invite_company_user_form.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/core/theme/app_icons.dart';

class CompanyUsersSection extends StatefulWidget {
  const CompanyUsersSection({super.key});

  @override
  State<CompanyUsersSection> createState() => _CompanyUsersSectionState();
}

class _CompanyUsersSectionState extends State<CompanyUsersSection> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  String _selectedRole = CompanyRoles.warehouseUser;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final companyId = context.requireCurrentCompanyId();
    final currentProfileId = context.requireCurrentProfileId();
    final currentRole = context.currentUserRole;
    final companyTimezone = context.currentCompany?.timezone;

    final canViewTeam = CompanyRolePermissions.canViewTeam(currentRole);

    if (!canViewTeam) {
      return const SizedBox.shrink();
    }

    final canInviteUsers = CompanyRolePermissions.canInviteUsers(currentRole);
    final canCancelInvitations = CompanyRolePermissions.canCancelInvitations(
      currentRole,
    );
    final canChangeMemberRoles = CompanyRolePermissions.canChangeMemberRole(
      currentRole,
    );
    final canDeactivateMembers = CompanyRolePermissions.canDeactivateMember(
      currentRole,
    );
    final canReactivateMembers = CompanyRolePermissions.canReactivateMember(
      currentRole,
    );

    final allowedInviteRoles = CompanyRolePermissions.assignableRolesFor(
      currentRole,
    );

    final selectedRole = allowedInviteRoles.contains(_selectedRole)
        ? _selectedRole
        : allowedInviteRoles.firstOrNull ?? CompanyRoles.warehouseUser;

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

        if (state.completedActionKey == CompanyUsersSubmissionKey.invite) {
          _emailController.clear();
          setState(() => _selectedRole = CompanyRoles.warehouseUser);
        }

        AppMessage.showSuccess(
          context,
          successMessageForActionKey(state.completedActionKey),
        );
      },
      child: BlocBuilder<CompanyUsersCubit, CompanyUsersState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const _TeamLoadingPanel();
          }

          if (state.hasError) {
            return _TeamErrorPanel(message: state.errorMessage!);
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1040;

              final invitePanel =
                  canInviteUsers && allowedInviteRoles.isNotEmpty
                  ? _TeamSectionPanel(
                      icon: AppIcons.personAddAlt1Outlined,
                      title: 'Invite Member',
                      subtitle:
                          'Send a workspace invitation using only the roles '
                          'allowed for your current access level.',
                      child: InviteCompanyUserForm(
                        formKey: _formKey,
                        emailController: _emailController,
                        selectedRole: selectedRole,
                        allowedRoles: allowedInviteRoles,
                        isSubmitting: state.isActionSubmitting(
                          CompanyUsersSubmissionKey.invite,
                        ),
                        onRoleChanged: (role) {
                          if (role == null) {
                            return;
                          }

                          setState(() => _selectedRole = role);
                        },
                        onInvitePressed: () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          context.read<CompanyUsersCubit>().inviteCompanyUser(
                            companyId: companyId,
                            email: _emailController.text,
                            role: selectedRole,
                          );
                        },
                      ),
                    )
                  : null;

              final membersPanel = _TeamSectionPanel(
                icon: AppIcons.badgeOutlined,
                title: 'Members Directory',
                subtitle:
                    'Review company members, roles, status, accountability '
                    'details, and available access actions.',
                trailing: _SectionCounter(text: '${state.members.length}'),
                child: CompanyMembersList(
                  members: state.members,
                  actorRole: currentRole,
                  currentProfileId: currentProfileId,
                  canChangeMemberRoles: canChangeMemberRoles,
                  canDeactivateMembers: canDeactivateMembers,
                  canReactivateMembers: canReactivateMembers,
                  isActionSubmitting: state.isActionSubmitting,
                  companyTimezone: companyTimezone,
                  onChangeRolePressed: (member) {
                    showChangeRoleDialog(
                      parentContext: context,
                      companyId: companyId,
                      actorRole: currentRole,
                      member: member,
                    );
                  },
                  onDeactivatePressed: (member) {
                    showDeactivateMemberDialog(
                      parentContext: context,
                      companyId: companyId,
                      member: member,
                    );
                  },
                  onReactivatePressed: (member) {
                    showReactivateMemberDialog(
                      parentContext: context,
                      companyId: companyId,
                      member: member,
                    );
                  },
                ),
              );

              final invitationsPanel = _TeamSectionPanel(
                icon: AppIcons.mailOutline,
                title: 'Invitations',
                subtitle:
                    'Track invited users, invitation status, expiry dates, '
                    'and cancellation access.',
                trailing: _SectionCounter(
                  text: '${state.companyInvitations.length}',
                ),
                child: CompanyInvitationsList(
                  invitations: state.companyInvitations,
                  canCancelInvitations: canCancelInvitations,
                  isActionSubmitting: state.isActionSubmitting,
                  companyTimezone: companyTimezone,
                  onCancelPressed: (invitationId) {
                    context.read<CompanyUsersCubit>().cancelInvitation(
                      companyId: companyId,
                      invitationId: invitationId,
                    );
                  },
                ),
              );

              final activityPanel = _TeamSectionPanel(
                icon: AppIcons.timelineOutlined,
                title: 'Team Activity',
                subtitle:
                    'Trusted lifecycle history for invitations, role changes, '
                    'and member access updates.',
                trailing: _SectionCounter(
                  text: '${state.companyUserLifecycleAuditLogs.length}',
                ),
                child: CompanyUserLifecycleAuditLogsList(
                  auditLogs: state.companyUserLifecycleAuditLogs,
                  companyTimezone: companyTimezone,
                ),
              );

              if (!isWide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (invitePanel != null) ...[invitePanel, const Gap(16)],
                    membersPanel,
                    const Gap(16),
                    invitationsPanel,
                    const Gap(16),
                    activityPanel,
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (invitePanel != null) ...[invitePanel, const Gap(18)],
                  membersPanel,
                  const Gap(18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: invitationsPanel),
                      const Gap(18),
                      Expanded(flex: 7, child: activityPanel),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _TeamSectionPanel extends StatelessWidget {
  const _TeamSectionPanel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlayDark.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: AppColors.accent, size: 22),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.title.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const Gap(12), trailing!],
            ],
          ),
          const Gap(18),
          child,
        ],
      ),
    );
  }
}

class _SectionCounter extends StatelessWidget {
  const _SectionCounter({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 34),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TeamLoadingPanel extends StatelessWidget {
  const _TeamLoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const CompanyUsersLoadingView();
  }
}

class _TeamErrorPanel extends StatelessWidget {
  const _TeamErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(AppIcons.errorOutline, color: AppColors.error),
          const Gap(12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
