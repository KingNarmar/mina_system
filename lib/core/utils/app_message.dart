import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';

enum AppMessageType { success, error, warning, info }

abstract class AppMessage {
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, type: AppMessageType.success);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, type: AppMessageType.error);
  }

  static void showWarning(BuildContext context, String message) {
    _show(context, message, type: AppMessageType.warning);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, type: AppMessageType.info);
  }

  static void _show(
    BuildContext context,
    String message, {
    required AppMessageType type,
  }) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final snackBarWidth = screenWidth >= 700 ? 520.0 : null;
    final snackBarMargin = snackBarWidth == null
        ? const EdgeInsets.fromLTRB(16, 0, 16, 16)
        : null;

    final config = _getConfig(type);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          width: snackBarWidth,
          margin: snackBarMargin,
          elevation: 8,
          backgroundColor: config.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          duration: const Duration(seconds: 4),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(config.icon, color: config.foregroundColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.caption.copyWith(
                    color: config.foregroundColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  static _AppMessageConfig _getConfig(AppMessageType type) {
    switch (type) {
      case AppMessageType.success:
        return const _AppMessageConfig(
          icon: Icons.check_circle_outline_rounded,
          backgroundColor: AppColors.success,
          foregroundColor: AppColors.onPrimary,
        );
      case AppMessageType.error:
        return const _AppMessageConfig(
          icon: Icons.error_outline_rounded,
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.onPrimary,
        );
      case AppMessageType.warning:
        return const _AppMessageConfig(
          icon: Icons.warning_amber_rounded,
          backgroundColor: AppColors.warning,
          foregroundColor: AppColors.primary,
        );
      case AppMessageType.info:
        return const _AppMessageConfig(
          icon: Icons.info_outline_rounded,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
        );
    }
  }
}

class _AppMessageConfig {
  const _AppMessageConfig({
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
}
