import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/routes/routes.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/company_users/data/models/company_invitation_model.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_cubit.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_state.dart';
import 'package:mina_system/features/current_context/data/models/company_model.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

        context.read<CurrentContextCubit>().loadCurrentContext(
          restoreLastSelectedCompany: false,
        );
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
              constraints: const BoxConstraints(maxWidth: 720),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: BlocBuilder<CompanyUsersCubit, CompanyUsersState>(
                  builder: (context, state) {
                    final pendingInvitations =
                        state.pendingCurrentUserInvitations;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.apartment_outlined,
                          size: 48,
                          color: AppColors.accent,
                        ),
                        const Gap(16),
                        const Text(
                          'Choose Workspace',
                          style: AppTextStyles.heading,
                          textAlign: TextAlign.center,
                        ),
                        const Gap(8),
                        const Text(
                          'Open one of your active companies or review any pending invitations.',
                          style: AppTextStyles.body,
                          textAlign: TextAlign.center,
                        ),
                        const Gap(24),
                        _CompaniesSection(
                          companies: companies,
                          onCompanySelected: onCompanySelected,
                        ),
                        if (pendingInvitations.isNotEmpty) ...[
                          const Gap(28),
                          _PendingInvitationsSection(
                            invitations: pendingInvitations,
                            isSubmitting: state.isSubmitting,
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

class _CompaniesSection extends StatelessWidget {
  const _CompaniesSection({
    required this.companies,
    required this.onCompanySelected,
  });

  final List<CompanyModel> companies;
  final ValueChanged<String> onCompanySelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Companies', style: AppTextStyles.title),
        const Gap(12),
        if (companies.isEmpty)
          const Text('No active companies found.', style: AppTextStyles.body)
        else
          Column(
            children: companies.map((company) {
              return _CompanyCard(
                company: company,
                onPressed: () => onCompanySelected(company.id),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard({required this.company, required this.onPressed});

  final CompanyModel company;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.business_outlined, color: AppColors.textSecondary),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(company.name, style: AppTextStyles.title),
                const Gap(4),
                Text(
                  CompanyRoles.label(company.role),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const Gap(12),
          SizedBox(
            width: 150,
            child: MainButton(text: 'Open Workspace', onPressed: onPressed),
          ),
        ],
      ),
    );
  }
}

class _PendingInvitationsSection extends StatelessWidget {
  const _PendingInvitationsSection({
    required this.invitations,
    required this.isSubmitting,
  });

  final List<CompanyInvitationModel> invitations;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pending Invitations', style: AppTextStyles.title),
        const Gap(12),
        Column(
          children: invitations.map((invitation) {
            return _PendingInvitationCard(
              invitation: invitation,
              isSubmitting: isSubmitting,
            );
          }).toList(),
        ),
      ],
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
            value: CompanyRoles.label(invitation.role),
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

String _formatDate(DateTime value) {
  return value.toLocal().toString().split('.').first;
}
