import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/auth/presentation/widgets/register_form.dart';

class RegisterDesktopLayout extends StatelessWidget {
  const RegisterDesktopLayout({super.key, required this.email});

  final String email;

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
                    style: AppTextStyles.heading.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const Gap(12),
                  Text(
                    'Create your company workspace',
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const Gap(16),
                  Text(
                    'Register your account, create your company, and start managing tool custody operations securely.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: SizedBox(width: 420, child: RegisterForm(email: email)),
            ),
          ),
        ],
      ),
    );
  }
}
