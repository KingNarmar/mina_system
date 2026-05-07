import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';

class PendingApprovalsHeader extends StatelessWidget {
  const PendingApprovalsHeader({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.verified_user_outlined, color: AppColors.accent),
        const Gap(10),
        Expanded(
          child: Text(
            'Pending Approvals',
            style: AppTextStyles.title.copyWith(color: AppColors.textPrimary),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.24)),
          ),
          child: Text(
            '$count Item${count == 1 ? '' : 's'}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
