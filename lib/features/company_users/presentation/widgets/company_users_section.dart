import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/company_users/data/models/company_invitation_model.dart';
import 'package:mina_system/features/company_users/data/models/company_member_model.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_cubit.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_state.dart';
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
          _successMessageForActionKey(state.completedActionKey),
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
                    _InviteUserForm(
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
                  _MembersList(
                    members: state.members,
                    actorRole: currentRole,
                    currentProfileId: currentProfileId,
                    canChangeMemberRoles: canChangeMemberRoles,
                    canDeactivateMembers: canDeactivateMembers,
                    canReactivateMembers: canReactivateMembers,
                    isActionSubmitting: state.isActionSubmitting,
                    onChangeRolePressed: (member) {
                      _showChangeRoleDialog(
                        parentContext: context,
                        companyId: companyId,
                        actorRole: currentRole,
                        member: member,
                      );
                    },
                    onDeactivatePressed: (member) {
                      _showDeactivateMemberDialog(
                        parentContext: context,
                        companyId: companyId,
                        member: member,
                      );
                    },
                    onReactivatePressed: (member) {
                      _showReactivateMemberDialog(
                        parentContext: context,
                        companyId: companyId,
                        member: member,
                      );
                    },
                  ),
                  const Gap(24),
                  _InvitationsList(
                    invitations: state.pendingCompanyInvitations,
                    canCancelInvitations: canCancelInvitations,
                    isActionSubmitting: state.isActionSubmitting,
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

  Future<void> _showChangeRoleDialog({
    required BuildContext parentContext,
    required String companyId,
    required String? actorRole,
    required CompanyMemberModel member,
  }) async {
    final availableRoles = CompanyRolePermissions.assignableRolesFor(
      actorRole,
    ).where((role) => role != CompanyRoles.normalize(member.role)).toList();

    if (availableRoles.isEmpty) {
      return;
    }

    var selectedRole = availableRoles.first;

    await showDialog<void>(
      context: parentContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Change Member Role'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    member.fullName?.trim().isNotEmpty == true
                        ? member.fullName!
                        : member.email ?? 'Selected member',
                    style: AppTextStyles.body,
                  ),
                  const Gap(12),
                  Text(
                    'Current role: ${CompanyRoles.label(member.role)}',
                    style: AppTextStyles.caption,
                  ),
                  const Gap(16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'New Role',
                      border: OutlineInputBorder(),
                    ),
                    items: availableRoles.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(CompanyRoles.label(role)),
                      );
                    }).toList(),
                    onChanged: (role) {
                      if (role == null) {
                        return;
                      }

                      setDialogState(() => selectedRole = role);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();

                    parentContext
                        .read<CompanyUsersCubit>()
                        .changeCompanyMemberRole(
                          companyId: companyId,
                          memberId: member.id,
                          newRole: selectedRole,
                        );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showDeactivateMemberDialog({
    required BuildContext parentContext,
    required String companyId,
    required CompanyMemberModel member,
  }) async {
    await showDialog<void>(
      context: parentContext,
      builder: (dialogContext) {
        final displayName = _memberDisplayName(member);

        return AlertDialog(
          title: const Text('Deactivate Member'),
          content: Text(
            '$displayName will lose access to this company until reactivated.',
            style: AppTextStyles.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                parentContext.read<CompanyUsersCubit>().deactivateCompanyMember(
                  companyId: companyId,
                  memberId: member.id,
                );
              },
              child: const Text('Deactivate'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showReactivateMemberDialog({
    required BuildContext parentContext,
    required String companyId,
    required CompanyMemberModel member,
  }) async {
    await showDialog<void>(
      context: parentContext,
      builder: (dialogContext) {
        final displayName = _memberDisplayName(member);

        return AlertDialog(
          title: const Text('Reactivate Member'),
          content: Text(
            '$displayName will regain company access according to their assigned role.',
            style: AppTextStyles.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                parentContext.read<CompanyUsersCubit>().reactivateCompanyMember(
                  companyId: companyId,
                  memberId: member.id,
                );
              },
              child: const Text('Reactivate'),
            ),
          ],
        );
      },
    );
  }
}

class _InviteUserForm extends StatelessWidget {
  const _InviteUserForm({
    required this.formKey,
    required this.emailController,
    required this.selectedRole,
    required this.allowedRoles,
    required this.isSubmitting,
    required this.onRoleChanged,
    required this.onInvitePressed,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final String selectedRole;
  final List<String> allowedRoles;
  final bool isSubmitting;
  final ValueChanged<String?> onRoleChanged;
  final VoidCallback onInvitePressed;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 700;

          final emailField = TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'User Email',
              border: OutlineInputBorder(),
            ),
            validator: _validateEmail,
          );

          final roleField = DropdownButtonFormField<String>(
            initialValue: selectedRole,
            decoration: const InputDecoration(
              labelText: 'Role',
              border: OutlineInputBorder(),
            ),
            items: allowedRoles.map((role) {
              return DropdownMenuItem(
                value: role,
                child: Text(CompanyRoles.label(role)),
              );
            }).toList(),
            onChanged: isSubmitting ? null : onRoleChanged,
          );

          final inviteButton = SizedBox(
            width: isCompact ? double.infinity : 160,
            child: MainButton(
              text: 'Invite',
              isLoading: isSubmitting,
              onPressed: onInvitePressed,
            ),
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                emailField,
                const Gap(12),
                roleField,
                const Gap(12),
                inviteButton,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: emailField),
              const Gap(12),
              Expanded(child: roleField),
              const Gap(12),
              inviteButton,
            ],
          );
        },
      ),
    );
  }

  static String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required';
    }

    final isValidEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

    if (!isValidEmail) {
      return 'Enter a valid email address';
    }

    return null;
  }
}

class _MembersList extends StatelessWidget {
  const _MembersList({
    required this.members,
    required this.actorRole,
    required this.currentProfileId,
    required this.canChangeMemberRoles,
    required this.canDeactivateMembers,
    required this.canReactivateMembers,
    required this.isActionSubmitting,
    required this.onChangeRolePressed,
    required this.onDeactivatePressed,
    required this.onReactivatePressed,
  });

  final List<CompanyMemberModel> members;
  final String? actorRole;
  final String currentProfileId;
  final bool canChangeMemberRoles;
  final bool canDeactivateMembers;
  final bool canReactivateMembers;
  final bool Function(String actionKey) isActionSubmitting;
  final ValueChanged<CompanyMemberModel> onChangeRolePressed;
  final ValueChanged<CompanyMemberModel> onDeactivatePressed;
  final ValueChanged<CompanyMemberModel> onReactivatePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Members', style: AppTextStyles.title),
        const Gap(12),
        if (members.isEmpty)
          const Text('No company members found.', style: AppTextStyles.body)
        else
          Column(
            children: members.map((member) {
              final isCurrentUser = member.profileId == currentProfileId;
              final canManageTargetRole =
                  CompanyRolePermissions.canManageTargetRole(
                    actorRole: actorRole,
                    targetRole: member.role,
                  );

              final normalizedStatus = member.status.trim().toLowerCase();
              final isActiveMember = normalizedStatus == 'active';
              final isInactiveMember = normalizedStatus == 'inactive';

              final canChangeRole =
                  canChangeMemberRoles && !isCurrentUser && canManageTargetRole;

              final canDeactivate =
                  canDeactivateMembers &&
                  !isCurrentUser &&
                  canManageTargetRole &&
                  isActiveMember;

              final canReactivate =
                  canReactivateMembers &&
                  !isCurrentUser &&
                  canManageTargetRole &&
                  isInactiveMember;

              final isChangeRoleSubmitting = isActionSubmitting(
                CompanyUsersSubmissionKey.changeRole(member.id),
              );

              final isDeactivateSubmitting = isActionSubmitting(
                CompanyUsersSubmissionKey.deactivateMember(member.id),
              );

              final isReactivateSubmitting = isActionSubmitting(
                CompanyUsersSubmissionKey.reactivateMember(member.id),
              );

              return _MemberRow(
                member: member,
                canChangeRole: canChangeRole,
                canDeactivate: canDeactivate,
                canReactivate: canReactivate,
                isChangeRoleSubmitting: isChangeRoleSubmitting,
                isDeactivateSubmitting: isDeactivateSubmitting,
                isReactivateSubmitting: isReactivateSubmitting,
                onChangeRolePressed: () => onChangeRolePressed(member),
                onDeactivatePressed: () => onDeactivatePressed(member),
                onReactivatePressed: () => onReactivatePressed(member),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.member,
    required this.canChangeRole,
    required this.canDeactivate,
    required this.canReactivate,
    required this.isChangeRoleSubmitting,
    required this.isDeactivateSubmitting,
    required this.isReactivateSubmitting,
    required this.onChangeRolePressed,
    required this.onDeactivatePressed,
    required this.onReactivatePressed,
  });

  final CompanyMemberModel member;
  final bool canChangeRole;
  final bool canDeactivate;
  final bool canReactivate;
  final bool isChangeRoleSubmitting;
  final bool isDeactivateSubmitting;
  final bool isReactivateSubmitting;
  final VoidCallback onChangeRolePressed;
  final VoidCallback onDeactivatePressed;
  final VoidCallback onReactivatePressed;

  @override
  Widget build(BuildContext context) {
    final displayName = _memberDisplayName(member);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(Icons.person_outline, color: AppColors.textSecondary),
          SizedBox(
            width: 220,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName, style: AppTextStyles.body),
                if (member.email != null) ...[
                  const Gap(4),
                  Text(member.email!, style: AppTextStyles.caption),
                ],
              ],
            ),
          ),
          _StatusBadge(text: CompanyRoles.label(member.role)),
          _StatusBadge(text: member.status),
          if (canChangeRole)
            SizedBox(
              width: 150,
              child: MainButton(
                text: 'Change Role',
                isLoading: isChangeRoleSubmitting,
                onPressed: onChangeRolePressed,
              ),
            ),
          if (canDeactivate)
            SizedBox(
              width: 130,
              child: MainButton(
                text: 'Deactivate',
                color: AppColors.warning,
                isLoading: isDeactivateSubmitting,
                onPressed: onDeactivatePressed,
              ),
            ),
          if (canReactivate)
            SizedBox(
              width: 130,
              child: MainButton(
                text: 'Reactivate',
                color: AppColors.success,
                isLoading: isReactivateSubmitting,
                onPressed: onReactivatePressed,
              ),
            ),
        ],
      ),
    );
  }
}

class _InvitationsList extends StatelessWidget {
  const _InvitationsList({
    required this.invitations,
    required this.canCancelInvitations,
    required this.isActionSubmitting,
    required this.onCancelPressed,
  });

  final List<CompanyInvitationModel> invitations;
  final bool canCancelInvitations;
  final bool Function(String actionKey) isActionSubmitting;
  final ValueChanged<String> onCancelPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pending Invitations', style: AppTextStyles.title),
        const Gap(12),
        if (invitations.isEmpty)
          const Text('No pending invitations.', style: AppTextStyles.body)
        else
          Column(
            children: invitations.map((invitation) {
              final isCancelSubmitting = isActionSubmitting(
                CompanyUsersSubmissionKey.cancelInvitation(invitation.id),
              );

              return _InvitationRow(
                invitation: invitation,
                canCancelInvitations: canCancelInvitations,
                isCancelSubmitting: isCancelSubmitting,
                onCancelPressed: onCancelPressed,
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _InvitationRow extends StatelessWidget {
  const _InvitationRow({
    required this.invitation,
    required this.canCancelInvitations,
    required this.isCancelSubmitting,
    required this.onCancelPressed,
  });

  final CompanyInvitationModel invitation;
  final bool canCancelInvitations;
  final bool isCancelSubmitting;
  final ValueChanged<String> onCancelPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(Icons.mail_outline, color: AppColors.textSecondary),
          SizedBox(
            width: 240,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invitation.email, style: AppTextStyles.body),
                const Gap(4),
                Text(
                  'Expires: ${_formatDate(invitation.expiresAt)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          _StatusBadge(text: CompanyRoles.label(invitation.role)),
          _StatusBadge(text: invitation.status),
          if (canCancelInvitations)
            SizedBox(
              width: 130,
              child: MainButton(
                text: 'Cancel',
                color: AppColors.warning,
                isLoading: isCancelSubmitting,
                onPressed: () => onCancelPressed(invitation.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.text});

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
      child: Text(text, style: AppTextStyles.caption),
    );
  }
}

String _memberDisplayName(CompanyMemberModel member) {
  return member.fullName?.trim().isNotEmpty == true
      ? member.fullName!
      : member.email ?? 'Unknown user';
}

String _successMessageForActionKey(String? actionKey) {
  if (actionKey == CompanyUsersSubmissionKey.invite) {
    return 'Invitation sent successfully.';
  }

  if (actionKey?.startsWith('change-role:') == true) {
    return 'Member role updated successfully.';
  }

  if (actionKey?.startsWith('deactivate-member:') == true) {
    return 'Member deactivated successfully.';
  }

  if (actionKey?.startsWith('reactivate-member:') == true) {
    return 'Member reactivated successfully.';
  }

  if (actionKey?.startsWith('cancel-invitation:') == true) {
    return 'Invitation cancelled successfully.';
  }

  return 'Company users updated.';
}

String _formatDate(DateTime value) {
  return value.toLocal().toString().split('.').first;
}
