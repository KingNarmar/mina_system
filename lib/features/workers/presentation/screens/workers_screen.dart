import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';

class WorkersScreen extends StatelessWidget {
  const WorkersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Workers', style: AppTextStyles.heading));
  }
}
