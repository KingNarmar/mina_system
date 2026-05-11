import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/responsive/responsive_layout.dart';
import 'package:mina_system/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mina_system/features/auth/presentation/layouts/login_desktop_layout.dart';
import 'package:mina_system/features/auth/presentation/layouts/login_mobile_layout.dart';
import 'package:mina_system/features/auth/presentation/layouts/login_tablet_layout.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: ResponsiveLayout(
        mobile: LoginMobileLayout(email: email),
        tablet: LoginTabletLayout(email: email),
        desktop: LoginDesktopLayout(email: email),
      ),
    );
  }
}
