import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';

class LoginDesktopLayout extends StatelessWidget {
  const LoginDesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Login Desktop Layout', style: AppTextStyles.heading),
      ),
    );
  }
}
