import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Tools', style: AppTextStyles.heading));
  }
}
