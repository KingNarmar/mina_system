import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/responsive/responsive_layout.dart';
import 'package:mina_system/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mina_system/features/auth/presentation/layouts/register_desktop_layout.dart';
import 'package:mina_system/features/auth/presentation/layouts/register_mobile_layout.dart';
import 'package:mina_system/features/auth/presentation/layouts/register_tablet_layout.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: const ResponsiveLayout(
        mobile: RegisterMobileLayout(),
        tablet: RegisterTabletLayout(),
        desktop: RegisterDesktopLayout(),
      ),
    );
  }
}