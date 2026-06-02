import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mina_system/core/constants/app_images.dart';
import 'package:mina_system/core/routes/routes.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/validators/app_validators.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mina_system/features/auth/presentation/cubit/auth_state.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordResetEmailSent) {
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text('Check Your Email'),
                content: Text(
                  'If an account exists for ${state.email}, a password reset email has been sent. Please check your inbox and follow the instructions.',
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
                'Forgot your password?',
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
              const Gap(8),
              const Text(
                'Enter your email address and we will send you a password reset link.',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const Gap(20),
              CustomTextFormField(
                hint: 'Email Address',
                controller: _emailController,
                validator: AppValidators.validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const Gap(20),
              MainButton(
                text: 'Send Reset Link',
                onPressed: _onSendResetLinkPressed,
                isLoading: state is AuthLoading,
              ),
              const Gap(12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Remember your password?',
                    style: AppTextStyles.caption,
                  ),
                  TextButton(
                    onPressed: () => context.go(Routes.login),
                    child: Text(
                      'Login',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _onSendResetLinkPressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthCubit>().sendPasswordResetEmail(
      email: _emailController.text,
    );
  }
}
