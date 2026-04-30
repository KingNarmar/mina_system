import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Dashboard', style: AppTextStyles.heading));
  }
}
