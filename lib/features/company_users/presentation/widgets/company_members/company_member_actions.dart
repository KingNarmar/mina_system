part of '../company_members_list.dart';

class _MemberActions extends StatelessWidget {
  const _MemberActions({
    required this.hasActions,
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

  final bool hasActions;
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
    if (!hasActions) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            'No available actions',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        if (canChangeRole)
          SizedBox(
            width: 142,
            child: MainButton(
              text: 'Change Role',
              isLoading: isChangeRoleSubmitting,
              onPressed: onChangeRolePressed,
            ),
          ),
        if (canDeactivate)
          SizedBox(
            width: 124,
            child: MainButton(
              text: 'Deactivate',
              color: AppColors.warning,
              isLoading: isDeactivateSubmitting,
              onPressed: onDeactivatePressed,
            ),
          ),
        if (canReactivate)
          SizedBox(
            width: 124,
            child: MainButton(
              text: 'Reactivate',
              color: AppColors.success,
              isLoading: isReactivateSubmitting,
              onPressed: onReactivatePressed,
            ),
          ),
      ],
    );
  }
}
