import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/transactions/data/models/custody_balance_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/format_quantity.dart';
import 'package:mina_system/features/transactions/presentation/widgets/custody_balance/card/custody_balance_info_row.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_icons.dart';

class CustodyBalanceCard extends StatelessWidget {
  const CustodyBalanceCard({super.key, required this.balance});

  final CustodyBalanceModel balance;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                  child: const Icon(
                    AppIcons.inventory2Outlined,
                    color: AppColors.accent,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    balance.workerName,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(16),
            CustodyBalanceInfoRow(
              label: 'HR Code',
              value: balance.workerHrCode,
            ),
            CustodyBalanceInfoRow(
              label: 'Tool',
              value: '${balance.toolName} (${balance.toolCode})',
            ),
            CustodyBalanceInfoRow(
              label: 'Balance',
              value:
                  '${formatQuantity(balance.balanceQuantity)} ${balance.unit}',
            ),
          ],
        ),
      ),
    );
  }
}
