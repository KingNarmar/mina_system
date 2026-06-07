import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mina_system/core/app_mode/app_mode_scope.dart';
import 'package:mina_system/core/constants/app_images.dart';
import 'package:mina_system/core/routes/routes.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/main_button.dart';

class DemoPlaceholderScreen extends StatelessWidget {
  const DemoPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appMode = AppModeScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Demo Workspace'), centerTitle: false),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                color: AppColors.card,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(AppImages.logo, height: 110),
                      const SizedBox(height: 20),
                      Text(
                        'Demo Mode Placeholder',
                        style: AppTextStyles.heading.copyWith(fontSize: 24),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'The demo route is now public and does not require a Supabase session. In the next steps, this screen will be connected to a local demo workspace.',
                        style: AppTextStyles.body,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      _ModeBadge(label: appMode.label),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DemoDetail(
                              label: 'Company',
                              value: 'Demo Marine Services LLC',
                            ),
                            SizedBox(height: 8),
                            _DemoDetail(label: 'User', value: 'Demo User'),
                            SizedBox(height: 8),
                            _DemoDetail(label: 'Role', value: 'Owner'),
                            SizedBox(height: 8),
                            _DemoDetail(label: 'Timezone', value: 'Asia/Dubai'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      MainButton(
                        text: 'Back to Welcome',
                        onPressed: () => context.go(Routes.welcome),
                      ),
                      const SizedBox(height: 12),
                      MainButton(
                        text: 'Sign In Instead',
                        color: AppColors.card,
                        onPressed: () => context.go(Routes.login),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeBadge extends StatelessWidget {
  const _ModeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.warning),
      ),
      child: Text(
        '$label Mode',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DemoDetail extends StatelessWidget {
  const _DemoDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.caption,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
