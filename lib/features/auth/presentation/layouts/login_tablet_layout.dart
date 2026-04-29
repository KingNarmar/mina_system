import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';

class LoginTabletLayout extends StatelessWidget {
  const LoginTabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Login Tablet Layout', style: AppTextStyles.heading),
      ),
    );
  }
}
