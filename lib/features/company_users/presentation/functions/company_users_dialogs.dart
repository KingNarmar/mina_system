import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/company_users/data/models/company_member_model.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_cubit.dart';
import 'package:mina_system/features/company_users/presentation/functions/company_users_helpers.dart';

Future<void> showChangeRoleDialog({
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
                  companyMemberDisplayName(member),
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

Future<void> showDeactivateMemberDialog({
  required BuildContext parentContext,
  required String companyId,
  required CompanyMemberModel member,
}) async {
  await showDialog<void>(
    context: parentContext,
    builder: (dialogContext) {
      final displayName = companyMemberDisplayName(member);

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

Future<void> showReactivateMemberDialog({
  required BuildContext parentContext,
  required String companyId,
  required CompanyMemberModel member,
}) async {
  await showDialog<void>(
    context: parentContext,
    builder: (dialogContext) {
      final displayName = companyMemberDisplayName(member);

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
