import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mina_system/core/constants/app_images.dart';
import 'package:mina_system/core/routes/routes.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/validators/app_validators.dart';
import 'package:mina_system/core/widgets/custom_text_form_field.dart';
import 'package:mina_system/core/widgets/main_button.dart';
import 'package:mina_system/core/widgets/password_text_form_field.dart';
import 'package:mina_system/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mina_system/features/auth/presentation/cubit/auth_state.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(AppImages.logo, height: 200),

              const Text(
                'Manage workers, tools, custody transactions, inventory records, photos, and reports in one secure system.',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const Gap(20),
              CustomTextFormField(
                hint: 'Email or Username',
                controller: _emailController,
                validator: AppValidators.validateEmailOrUsername,
                keyboardType: TextInputType.emailAddress,
              ),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {},
              child: Text(
                'Forget password?',
                style: AppTextStyles.caption.copyWith(color: Colors.blue),
              ),
            ),
          ],
        ),
        const PasswordTextFormField(),
        const Gap(20),
        MainButton(text: 'Login', onPressed: () {}),
        const Gap(20),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            AppImages.loginPic,
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}
