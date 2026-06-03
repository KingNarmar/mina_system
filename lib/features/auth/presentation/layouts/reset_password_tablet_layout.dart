import 'package:flutter/material.dart';
import 'package:mina_system/features/auth/presentation/widgets/reset_password_form.dart';

class ResetPasswordTabletLayout extends StatelessWidget {
  const ResetPasswordTabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: SizedBox(width: 420, child: ResetPasswordForm()),
          ),
        ),
      ),
    );
  }
}
