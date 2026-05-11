import 'package:flutter/material.dart';
import 'package:mina_system/features/auth/presentation/widgets/login_form.dart';

class LoginMobileLayout extends StatelessWidget {
  const LoginMobileLayout({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: LoginForm(email: email),
          ),
        ),
      ),
    );
  }
}
