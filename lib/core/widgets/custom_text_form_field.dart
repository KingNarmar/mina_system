import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.hint,
    this.keyboardType,
    this.validator,
    this.icon,
    this.controller,
    this.focusNode,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.contentPadding,
    this.hintStyle,
    this.textStyle,
  });

  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? icon;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool readOnly;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AppColors.border;
    final effectiveFocusedBorderColor =
        focusedBorderColor ?? effectiveBorderColor;

    return TextFormField(
      focusNode: focusNode,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      controller: controller,
      style: textStyle,
      decoration: InputDecoration(
        contentPadding: contentPadding ?? const EdgeInsets.all(16),
        filled: true,
        fillColor: fillColor ?? AppColors.border,
        hintText: hint,
        hintStyle: hintStyle ?? AppTextStyles.caption,
        prefixIcon: icon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: effectiveBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: effectiveFocusedBorderColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
