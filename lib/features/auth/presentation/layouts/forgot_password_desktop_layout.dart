import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/auth/presentation/widgets/forgot_password_form.dart';

class ForgotPasswordDesktopLayout extends StatelessWidget {
  const ForgotPasswordDesktopLayout({super.key});

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
                    'Recover account access',
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const Gap(16),
                  Text(
                    'Send a secure password reset email and regain access without developer intervention.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: SizedBox(width: 420, child: ForgotPasswordForm()),
            ),
          ),
        ],
      ),
    );
  }
}
