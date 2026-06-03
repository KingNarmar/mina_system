import 'package:flutter/material.dart';
import 'package:mina_system/features/auth/presentation/widgets/reset_password_form.dart';

class ResetPasswordMobileLayout extends StatelessWidget {
  const ResetPasswordMobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: ResetPasswordForm(),
          ),
        ),
      ),
    );
  }
}
