import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';

class TransactionsTableHeaderCell extends StatelessWidget {
  const TransactionsTableHeaderCell({
    super.key,
    required this.title,
    required this.flex,
  });

  final String title;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class TransactionsTableBodyCell extends StatelessWidget {
  const TransactionsTableBodyCell({
    super.key,
    required this.value,
    required this.flex,
  });

  final String value;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        value,
        style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
