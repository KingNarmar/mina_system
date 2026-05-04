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
import 'package:mina_system/core/widgets/password_text_form_field.dart';
import 'package:mina_system/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mina_system/features/auth/presentation/cubit/auth_state.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthRegisterSuccess) {
          if (state.requiresEmailConfirmation) {
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) {
                return AlertDialog(
                  title: const Text('Confirm Your Email'),
                  content: const Text(
                    'Your account has been created successfully. Please check your email inbox and confirm your account before logging in.',
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
            return;
          }

          context.go(Routes.dashboard);
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
                'Create your M.I.N.A System account',
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
              const Gap(8),
              const Text(
                'Start your company workspace and manage tool custody securely.',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const Gap(20),
              CustomTextFormField(
                hint: 'Full Name',
                controller: _fullNameController,
                validator: AppValidators.validateFullName,
                keyboardType: TextInputType.name,
              ),
              const Gap(12),
              CustomTextFormField(
                hint: 'Email',
                controller: _emailController,
                validator: AppValidators.validateEmailOrUsername,
                keyboardType: TextInputType.emailAddress,
              ),
              const Gap(12),
              PasswordTextFormField(
                hint: 'Password',
                passwordController: _passwordController,
                validator: AppValidators.validatePassword,
              ),
              const Gap(12),
              PasswordTextFormField(
                hint: 'Confirm Password',
                passwordController: _confirmPasswordController,
                validator: _validateConfirmPassword,
              ),
              const Gap(20),
              MainButton(
                text: 'Create Account',
                onPressed: _onRegisterPressed,
                isLoading: state is AuthLoading,
              ),
              const Gap(12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account?',
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

  void _onRegisterPressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthCubit>().register(
      fullName: _fullNameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );
  }
}
