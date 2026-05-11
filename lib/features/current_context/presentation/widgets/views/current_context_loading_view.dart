import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';

class CurrentContextLoadingView extends StatelessWidget {
  const CurrentContextLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
