import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mina_system/core/constants/app_images.dart';
import 'package:mina_system/core/routes/routes.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/validators/app_validators.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';
import 'package:mina_system/core/widgets/main_button.dart';

class EmailEntryForm extends StatefulWidget {
  const EmailEntryForm({super.key});

  @override
  State<EmailEntryForm> createState() => _EmailEntryFormState();
}

class _EmailEntryFormState extends State<EmailEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _showChoice = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(AppImages.logo, height: 150),
          const Text(
            'Manage workers, tools, custody transactions, inventory records, photos, and reports in one secure system.',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const Gap(24),
          CustomTextFormField(
            hint: 'Email Address',
            controller: _emailController,
            validator: AppValidators.validateEmail,
            keyboardType: TextInputType.emailAddress,
            readOnly: _showChoice,
          ),
          const Gap(20),
          if (!_showChoice)
            MainButton(text: 'Continue', onPressed: _onContinuePressed)
          else ...[
            const Text(
              'What would you like to do?',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            MainButton(
              text: 'I already have an account',
              onPressed: () =>
                  context.go(Routes.login, extra: _emailController.text.trim()),
            ),
            const Gap(12),
            MainButton(
              text: 'Create a new account',
              color: AppColors.card,
              onPressed: () => context.go(
                Routes.register,
                extra: _emailController.text.trim(),
              ),
            ),
            const Gap(12),
            TextButton(
              onPressed: () {
                setState(() => _showChoice = false);
              },
              child: Text(
                'Use a different email',
                style: AppTextStyles.caption.copyWith(color: AppColors.accent),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _onContinuePressed() {
    if (_formKey.currentState!.validate()) {
      setState(() => _showChoice = true);
    }
  }
}
