import 'package:flutter/material.dart';
import 'package:mina_system/core/responsive/responsive_layout.dart';
import 'package:mina_system/features/auth/presentation/layouts/login_desktop_layout.dart';
import 'package:mina_system/features/auth/presentation/layouts/login_mobile_layout.dart';
import 'package:mina_system/features/auth/presentation/layouts/login_tablet_layout.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: LoginMobileLayout(),
      tablet: LoginTabletLayout(),
      desktop: LoginDesktopLayout(),
    );
  }
}
