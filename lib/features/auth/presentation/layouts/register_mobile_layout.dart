import 'package:flutter/material.dart';
import 'package:mina_system/features/auth/presentation/widgets/register_form.dart';

class RegisterMobileLayout extends StatelessWidget {
  const RegisterMobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(padding: EdgeInsets.all(20), child: RegisterForm()),
        ),
      ),
    );
  }
}
