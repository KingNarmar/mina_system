import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';

class DesktopShell extends StatelessWidget {
  const DesktopShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 260,
            color: AppColors.primary,
            child: const Center(
              child: Text(
                'M.I.N.A System',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const Expanded(child: Center(child: Text('Desktop Dashboard Shell'))),
        ],
      ),
    );
  }
}
