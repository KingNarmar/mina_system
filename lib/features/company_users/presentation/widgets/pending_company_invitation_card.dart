import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/company_users/data/models/company_invitation_model.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_cubit.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_state.dart';

class PendingCompanyInvitationCard extends StatelessWidget {
  const PendingCompanyInvitationCard({super.key, required this.invitation});

  final CompanyInvitationModel invitation;

  @override
  Widget build(BuildContext context) {
    final companyName = invitation.companyName?.trim().isNotEmpty == true
        ? invitation.companyName!
        : 'Company Invitation';

    final invitedByName = invitation.invitedByName?.trim().isNotEmpty == true
        ? invitation.invitedByName!
        : 'Unknown';

    final roleLabel = CompanyRoles.label(invitation.role);
    final roleColor = _roleColor(invitation.role);
    final actionKey = CompanyUsersSubmissionKey.acceptInvitation(invitation.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlayDark.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 5, color: roleColor),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InvitationIcon(color: roleColor),
                      const Gap(14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              companyName,
                              style: AppTextStyles.title.copyWith(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Gap(8),
                            _RoleBadge(label: roleLabel, color: roleColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  _InvitationDetailsPanel(
                    invitedEmail: invitation.email,
                    invitedByName: invitedByName,
                    invitedByEmail: invitation.invitedByEmail,
                    expiresAt: invitation.expiresAt,
                  ),
                  const Gap(16),
                  BlocBuilder<CompanyUsersCubit, CompanyUsersState>(
                    buildWhen: (previous, current) {
                      return previous.isSubmitting != current.isSubmitting ||
                          previous.submittingActionKey !=
                              current.submittingActionKey;
                    },
                    builder: (context, state) {
                      final isAccepting = state.isActionSubmitting(actionKey);

                      return MainButton(
                        text: 'Accept Invitation',
                        isLoading: isAccepting,
                        onPressed: () {
                          context.read<CompanyUsersCubit>().acceptInvitation(
                            invitationId: invitation.id,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvitationDetailsPanel extends StatelessWidget {
  const _InvitationDetailsPanel({
    required this.invitedEmail,
    required this.invitedByName,
    required this.invitedByEmail,
    required this.expiresAt,
  });

  final String invitedEmail;
  final String invitedByName;
  final String? invitedByEmail;
  final DateTime expiresAt;

  @override
  Widget build(BuildContext context) {
    final cleanInvitedByEmail = invitedByEmail?.trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _InvitationDetailRow(
            icon: Icons.alternate_email,
            label: 'Invited email',
            value: invitedEmail,
          ),
          const Gap(10),
          _InvitationDetailRow(
            icon: Icons.person_outline,
            label: 'Invited by',
            value: invitedByName,
          ),
          if (cleanInvitedByEmail != null &&
              cleanInvitedByEmail.isNotEmpty) ...[
            const Gap(6),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(
                  cleanInvitedByEmail,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          const Gap(10),
          _InvitationDetailRow(
            icon: Icons.event_outlined,
            label: 'Expires',
            value: _formatDate(expiresAt),
          ),
        ],
      ),
    );
  }
}

class _InvitationDetailRow extends StatelessWidget {
  const _InvitationDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const Gap(12),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _InvitationIcon extends StatelessWidget {
  const _InvitationIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.mark_email_unread_rounded, color: color, size: 24),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

Color _roleColor(String? role) {
  switch (CompanyRoles.normalize(role)) {
    case CompanyRoles.owner:
      return AppColors.primary;
    case CompanyRoles.admin:
      return AppColors.accent;
    case CompanyRoles.warehouseManager:
      return AppColors.success;
    case CompanyRoles.warehouseUser:
      return AppColors.warning;
    case CompanyRoles.viewer:
      return AppColors.textSecondary;
    default:
      return AppColors.textSecondary;
  }
}

String _formatDate(DateTime value) {
  return value.toLocal().toString().split('.').first;
}
