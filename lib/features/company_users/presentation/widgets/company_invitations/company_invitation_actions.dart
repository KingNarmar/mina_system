part of '../company_invitations_list.dart';

class _InvitationAction extends StatelessWidget {
  const _InvitationAction({
    required this.canCancel,
    required this.isCancelSubmitting,
    required this.onCancelPressed,
  });

  final bool canCancel;
  final bool isCancelSubmitting;
  final VoidCallback onCancelPressed;

  @override
  Widget build(BuildContext context) {
    if (!canCancel) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: MainButton(
        text: 'Cancel',
        color: AppColors.warning,
        isLoading: isCancelSubmitting,
        onPressed: onCancelPressed,
      ),
    );
  }
}
