import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/auth/presentation/widgets/reset_password_form.dart';

class ResetPasswordDesktopLayout extends StatelessWidget {
  const ResetPasswordDesktopLayout({super.key});

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
                    'Create a new password',
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const Gap(16),
                  Text(
                    'Set a new secure password for your account and return to login.',
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
              child: SizedBox(width: 420, child: ResetPasswordForm()),
            ),
          ),
        ],
      ),
    );
  }
}
