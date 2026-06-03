import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/responsive/responsive_layout.dart';
import 'package:mina_system/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mina_system/features/auth/presentation/layouts/reset_password_desktop_layout.dart';
import 'package:mina_system/features/auth/presentation/layouts/reset_password_mobile_layout.dart';
import 'package:mina_system/features/auth/presentation/layouts/reset_password_tablet_layout.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: const ResponsiveLayout(
        mobile: ResetPasswordMobileLayout(),
        tablet: ResetPasswordTabletLayout(),
        desktop: ResetPasswordDesktopLayout(),
      ),
    );
  }
}
