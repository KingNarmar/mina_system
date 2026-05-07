import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';

class PendingApprovalStatusChip extends StatelessWidget {
  const PendingApprovalStatusChip({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String formatPendingApprovalStatus(String value) {
  return value
      .trim()
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) {
        return '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}';
      })
      .join(' ');
}

String formatPendingApprovalQuantity(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }

  return value.toString();
}

Color getApprovalStatusColor(String status) {
  switch (status.trim().toLowerCase()) {
    case 'approved':
      return AppColors.success;
    case 'rejected':
      return AppColors.error;
    case 'pending':
      return AppColors.warning;
    case 'not_required':
    default:
      return AppColors.textSecondary;
  }
}

Color getSettlementStatusColor(String status) {
  switch (status.trim().toLowerCase()) {
    case 'settled':
      return AppColors.success;
    case 'pending_settlement':
      return AppColors.warning;
    case 'not_required':
    default:
      return AppColors.textSecondary;
  }
}
