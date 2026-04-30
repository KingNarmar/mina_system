import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';

class PasswordTextFormField extends StatefulWidget {
  const PasswordTextFormField({
    super.key,
    this.validator,
    this.hint,
    this.passwordController,
  });

  final String? Function(String?)? validator;
  final String? hint;
  final TextEditingController? passwordController;
  @override
  State<PasswordTextFormField> createState() => _PasswordTextFormFieldState();
}

class _PasswordTextFormFieldState extends State<PasswordTextFormField> {
  bool ishide = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: TextFormField(
        controller: widget.passwordController,
        obscureText: ishide,
        keyboardType: TextInputType.visiblePassword,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        decoration: InputDecoration(
          fillColor: AppColors.border,
          filled: true,
          suffixIcon: IconButton(
            icon: ishide
                ? const Icon(Icons.remove_red_eye)
                : const Icon(Icons.visibility_off),
            onPressed: () {
              setState(() {
                ishide = !ishide;
              });
            },
          ),
          hintText: widget.hint ?? 'Password',
          hintStyle: AppTextStyles.caption,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.error),
          ),
        ),
        validator: widget.validator,
        onChanged: (value) {},
      ),
    );
  }
}
