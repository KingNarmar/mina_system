import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/auth/presentation/widgets/login_form.dart';

class LoginDesktopLayout extends StatelessWidget {
  const LoginDesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Expanded(
            child: Container(
              color: AppColors.primary,
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'M.I.N.A System',
                    style: AppTextStyles.heading.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Materials Inventory Navigation Assistant',
                    style: AppTextStyles.title.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'A smart custody and inventory management platform for modern warehouses.',
                    style: AppTextStyles.body.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ), // left branding section
          ),
          const Expanded(
            child: Center(child: SizedBox(width: 420, child: LoginForm())),
          ),
        ],
      ),
    );
  }
}
