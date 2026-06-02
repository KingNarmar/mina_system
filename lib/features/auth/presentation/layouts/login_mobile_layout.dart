import 'package:flutter/material.dart';
import 'package:mina_system/features/auth/presentation/widgets/login_form.dart';

class LoginMobileLayout extends StatelessWidget {
  const LoginMobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(padding: EdgeInsets.all(20), child: LoginForm()),
        ),
      ),
    );
  }
}
