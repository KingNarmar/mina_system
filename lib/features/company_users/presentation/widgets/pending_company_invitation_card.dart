import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/company_users/data/models/company_invitation_model.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_cubit.dart';

class PendingCompanyInvitationCard extends StatelessWidget {
  const PendingCompanyInvitationCard({
    super.key,
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
