import 'package:flutter/material.dart';
import 'package:mina_system/features/auth/presentation/widgets/login_form.dart';

class LoginTabletLayout extends StatelessWidget {
  const LoginTabletLayout({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: SizedBox(width: 420, child: LoginForm(email: email)),
          ),
        ),
      ),
    );
  }
}
