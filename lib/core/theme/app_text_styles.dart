import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';

abstract class AppTextStyles {
  static const heading = TextStyle(
    fontSize: 28,
    height: 1.29,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const title = TextStyle(
    fontSize: 22,
    height: 1.27,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const caption = TextStyle(
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}
