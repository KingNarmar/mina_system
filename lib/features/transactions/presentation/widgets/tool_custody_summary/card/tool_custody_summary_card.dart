import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/transactions/data/models/tool_custody_summary_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/format_quantity.dart';
import 'package:mina_system/features/transactions/presentation/widgets/tool_custody_summary/card/tool_custody_summary_info_row.dart';
import 'package:gap/gap.dart';

class ToolCustodySummaryCard extends StatelessWidget {
  const ToolCustodySummaryCard({super.key, required this.summary});

  final ToolCustodySummaryModel summary;

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
                    Icons.build_outlined,
                    color: AppColors.accent,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    summary.toolName,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(16),
            ToolCustodySummaryInfoRow(
              label: 'Tool Code',
              value: summary.toolCode,
            ),
            ToolCustodySummaryInfoRow(
              label: 'Open Custody',
              value:
                  '${formatQuantity(summary.openCustodyQuantity)} ${summary.unit}',
            ),
            ToolCustodySummaryInfoRow(
              label: 'Issued',
              value:
                  '${formatQuantity(summary.issuedQuantity)} ${summary.unit}',
            ),
            ToolCustodySummaryInfoRow(
              label: 'Returned',
              value:
                  '${formatQuantity(summary.returnedQuantity)} ${summary.unit}',
            ),
            ToolCustodySummaryInfoRow(
              label: 'Lost',
              value: '${formatQuantity(summary.lostQuantity)} ${summary.unit}',
            ),
            ToolCustodySummaryInfoRow(
              label: 'Damaged',
              value:
                  '${formatQuantity(summary.damagedQuantity)} ${summary.unit}',
            ),
            ToolCustodySummaryInfoRow(
              label: 'Movements',
              value: summary.totalMovements.toString(),
            ),
          ],
        ),
      ),
    );
  }
}
