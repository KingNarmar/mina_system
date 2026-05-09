import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mina_system/core/routes/routes.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/company_users/data/models/company_invitation_model.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_cubit.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_state.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PendingCompanyInvitationsScreen extends StatelessWidget {
  const PendingCompanyInvitationsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();

    if (!context.mounted) {
      return;
    }

    context.go(Routes.login);
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

        context.read<CurrentContextCubit>().loadCurrentContext();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          actions: [
            TextButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: BlocBuilder<CompanyUsersCubit, CompanyUsersState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.hasError) {
                      return _PendingInvitationsErrorView(
                        message: state.errorMessage!,
                      );
                    }

                    final invitations = state.pendingInvitations;

                    if (invitations.isEmpty) {
                      return const _NoPendingInvitationsView();
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.mark_email_unread_outlined,
                          size: 48,
                          color: AppColors.accent,
                        ),
                        const Gap(16),
                        const Text(
                          'Company Invitations',
                          style: AppTextStyles.heading,
                          textAlign: TextAlign.center,
                        ),
                        const Gap(8),
                        const Text(
                          'Review the invitation details before joining the company workspace.',
                          style: AppTextStyles.body,
                          textAlign: TextAlign.center,
                        ),
                        const Gap(24),
                        ...invitations.map((invitation) {
                          return _PendingInvitationCard(
                            invitation: invitation,
                            isSubmitting: state.isSubmitting,
                          );
                        }),
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

class _PendingInvitationCard extends StatelessWidget {
  const _PendingInvitationCard({
    required this.invitation,
    required this.isSubmitting,
  });

  final CompanyInvitationModel invitation;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final companyName = invitation.companyName?.trim().isNotEmpty == true
        ? invitation.companyName!
        : 'Company Invitation';

    final invitedByName = invitation.invitedByName?.trim().isNotEmpty == true
        ? invitation.invitedByName!
        : 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(companyName, style: AppTextStyles.title),
          const Gap(12),
          _InvitationDetailRow(label: 'Invited email', value: invitation.email),
          const Gap(8),
          _InvitationDetailRow(label: 'Invited by', value: invitedByName),
          if (invitation.invitedByEmail != null &&
              invitation.invitedByEmail!.trim().isNotEmpty) ...[
            const Gap(4),
            Text(invitation.invitedByEmail!, style: AppTextStyles.caption),
          ],
          const Gap(8),
          _InvitationDetailRow(
            label: 'Role',
            value: _roleLabel(invitation.role),
          ),
          const Gap(8),
          _InvitationDetailRow(
            label: 'Expires',
            value: _formatDate(invitation.expiresAt),
          ),
          const Gap(16),
          MainButton(
            text: 'Accept Invitation',
            isLoading: isSubmitting,
            onPressed: () {
              context.read<CompanyUsersCubit>().acceptInvitation(
                invitationId: invitation.id,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InvitationDetailRow extends StatelessWidget {
  const _InvitationDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text('$label: $value', style: AppTextStyles.body);
  }
}

class _PendingInvitationsErrorView extends StatelessWidget {
  const _PendingInvitationsErrorView({required this.message});

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

class _NoPendingInvitationsView extends StatelessWidget {
  const _NoPendingInvitationsView();

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

String _roleLabel(String role) {
  switch (role) {
    case 'owner':
      return 'Owner';
    case 'admin':
      return 'Admin';
    case 'warehouse_manager':
      return 'Warehouse Manager';
    case 'warehouse_user':
      return 'Warehouse User';
    case 'viewer':
      return 'Viewer';
    default:
      return role;
  }
}

String _formatDate(DateTime value) {
  return value.toLocal().toString().split('.').first;
}
