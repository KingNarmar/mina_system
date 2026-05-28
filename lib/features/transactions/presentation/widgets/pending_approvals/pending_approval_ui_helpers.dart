part of 'pending_approval_actions.dart';

class _ActionButtonLoader extends StatelessWidget {
  const _ActionButtonLoader();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
