import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mina_system/core/constants/app_images.dart';
import 'package:mina_system/core/routes/routes.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/validators/app_validators.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/core/widgets/password_text_form_field.dart';
import 'package:mina_system/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mina_system/features/auth/presentation/cubit/auth_state.dart';

class ResetPasswordForm extends StatefulWidget {
  const ResetPasswordForm({super.key});

  @override
  State<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordUpdated) {
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text('Password Updated'),
                content: const Text(
                  'Your password has been updated successfully. Please login again using your new password.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      context.go(Routes.login);
                    },
                    child: const Text('Back to Login'),
                  ),
                ],
              );
            },
          );
        }

        if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(AppImages.logo, height: 120),
              const Gap(12),
              const Text(
                'Reset your password',
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
              const Gap(8),
              const Text(
                'Enter and confirm your new password.',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const Gap(20),
              PasswordTextFormField(
                hint: 'New Password',
                passwordController: _passwordController,
                validator: AppValidators.validatePassword,
              ),
              const Gap(12),
              PasswordTextFormField(
                hint: 'Confirm New Password',
                passwordController: _confirmPasswordController,
                validator: _validateConfirmPassword,
              ),
              const Gap(20),
              MainButton(
                text: 'Update Password',
                onPressed: _onUpdatePasswordPressed,
                isLoading: state is AuthLoading,
              ),
              const Gap(12),
              TextButton(
                onPressed: () => context.go(Routes.login),
                child: Text(
                  'Back to Login',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String? _validateConfirmPassword(String? value) {
    final confirmPassword = value?.trim() ?? '';

    if (confirmPassword.isEmpty) {
      return 'Confirm password is required';
    }

    if (confirmPassword != _passwordController.text.trim()) {
      return 'Passwords do not match';
    }

    return null;
  }

  void _onUpdatePasswordPressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthCubit>().updatePassword(
      password: _passwordController.text,
    );
  }
}
