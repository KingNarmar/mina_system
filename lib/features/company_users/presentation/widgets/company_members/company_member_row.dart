part of '../company_members_list.dart';

class CompanyMemberRow extends StatelessWidget {
  const CompanyMemberRow({
    super.key,
    required this.member,
    required this.isCurrentUser,
    required this.canChangeRole,
    required this.canDeactivate,
    required this.canReactivate,
    required this.isChangeRoleSubmitting,
    required this.isDeactivateSubmitting,
    required this.isReactivateSubmitting,
    required this.onChangeRolePressed,
    required this.onDeactivatePressed,
    required this.onReactivatePressed,
    this.companyTimezone,
  });

  final CompanyMemberModel member;
  final bool isCurrentUser;
  final bool canChangeRole;
  final bool canDeactivate;
  final bool canReactivate;
  final bool isChangeRoleSubmitting;
  final bool isDeactivateSubmitting;
  final bool isReactivateSubmitting;
  final VoidCallback onChangeRolePressed;
  final VoidCallback onDeactivatePressed;
  final VoidCallback onReactivatePressed;
  final String? companyTimezone;

  @override
  Widget build(BuildContext context) {
    final displayName = companyMemberDisplayName(member);
    final email = member.email?.trim();
    final hasEmail = email != null && email.isNotEmpty;

    final hasActions = canChangeRole || canDeactivate || canReactivate;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 720;

          final identity = _MemberIdentity(
            displayName: displayName,
            email: hasEmail ? email : null,
            role: member.role,
            status: member.status,
            isCurrentUser: isCurrentUser,
          );

          final details = _MemberAccountabilityPanel(
            member: member,
            companyTimezone: companyTimezone,
          );

          final actions = _MemberActions(
            hasActions: hasActions,
            canChangeRole: canChangeRole,
            canDeactivate: canDeactivate,
            canReactivate: canReactivate,
            isChangeRoleSubmitting: isChangeRoleSubmitting,
            isDeactivateSubmitting: isDeactivateSubmitting,
            isReactivateSubmitting: isReactivateSubmitting,
            onChangeRolePressed: onChangeRolePressed,
            onDeactivatePressed: onDeactivatePressed,
            onReactivatePressed: onReactivatePressed,
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                identity,
                const Gap(14),
                details,
                const Gap(14),
                actions,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: identity),
                  const Gap(18),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: actions,
                  ),
                ],
              ),
              const Gap(14),
              details,
            ],
          );
        },
      ),
    );
  }
}
