import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_cubit.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_state.dart';
import 'package:mina_system/features/company_users/presentation/functions/company_users_dialogs.dart';
import 'package:mina_system/features/company_users/presentation/functions/company_users_helpers.dart';
import 'package:mina_system/features/company_users/presentation/widgets/company_invitations_list.dart';
import 'package:mina_system/features/company_users/presentation/widgets/company_members_list.dart';
import 'package:mina_system/features/company_users/presentation/widgets/invite_company_user_form.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';

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
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Company Users', style: AppTextStyles.title),
                const Gap(8),
                const Text(
                  'Manage company members and pending invitations.',
                  style: AppTextStyles.body,
                ),
                const Gap(20),
                if (state.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (state.hasError)
                  Text(
                    state.errorMessage!,
                    style: AppTextStyles.body.copyWith(color: AppColors.error),
                  )
                else ...[
                  if (canInviteUsers && allowedInviteRoles.isNotEmpty) ...[
                    InviteCompanyUserForm(
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
                    const Gap(24),
                  ],
                  CompanyMembersList(
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
                  const Gap(24),
                  CompanyInvitationsList(
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
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
