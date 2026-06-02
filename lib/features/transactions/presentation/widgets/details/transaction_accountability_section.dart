import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_icons.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/format_transaction_date.dart';

class TransactionAccountabilitySection extends StatelessWidget {
  const TransactionAccountabilitySection({
    super.key,
    required this.transaction,
  });

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final timezone = context.currentCompany?.timezone;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: AppIcons.verifiedUser,
            title: 'Accountability',
          ),
          const Gap(12),

          _AccountabilityRow(
            label: 'Created by',
            value: transaction.createdByDisplayName,
          ),
          _AccountabilityRow(
            label: 'Created at',
            value: _formatNullableDate(
              transaction.dateTime,
              timezone: timezone,
            ),
          ),

          const Gap(10),
          const Divider(height: 1, color: AppColors.border),
          const Gap(10),

          _AccountabilityRow(
            label: 'Proof image',
            value: transaction.hasProofImage ? 'Attached' : 'Not attached',
          ),
          _AccountabilityRow(
            label: 'Proof uploaded by',
            value: transaction.hasProofImage
                ? transaction.proofImageUploadedByDisplayName
                : '-',
          ),
          _AccountabilityRow(
            label: 'Proof uploaded at',
            value: transaction.hasProofImage
                ? _formatNullableDate(
                    transaction.proofImageUploadedAt,
                    timezone: timezone,
                  )
                : '-',
          ),

          if (transaction.isLostOrDamaged) ...[
            const Gap(10),
            const Divider(height: 1, color: AppColors.border),
            const Gap(10),

            _AccountabilityRow(
              label: 'Document uploaded by',
              value: transaction.hasApprovalDocument
                  ? transaction.approvalDocumentUploadedByDisplayName
                  : '-',
            ),
            _AccountabilityRow(
              label: 'Document uploaded at',
              value: transaction.hasApprovalDocument
                  ? _formatNullableDate(
                      transaction.approvalDocumentUploadedAt,
                      timezone: timezone,
                    )
                  : '-',
            ),
            _AccountabilityRow(
              label: 'Decision by',
              value: transaction.approvalDecidedAt == null
                  ? '-'
                  : transaction.approvalDecidedByDisplayName,
            ),
            _AccountabilityRow(
              label: 'Decision at',
              value: _formatNullableDate(
                transaction.approvalDecidedAt,
                timezone: timezone,
              ),
            ),
            _AccountabilityRow(
              label: 'Settlement by',
              value: transaction.settledAt == null
                  ? '-'
                  : transaction.settledByDisplayName,
            ),
            _AccountabilityRow(
              label: 'Settlement at',
              value: _formatNullableDate(
                transaction.settledAt,
                timezone: timezone,
              ),
            ),
          ],

          if (transaction.isVoided) ...[
            const Gap(10),
            const Divider(height: 1, color: AppColors.border),
            const Gap(10),

            _AccountabilityRow(
              label: 'Voided by',
              value: transaction.voidedByDisplayName,
            ),
            _AccountabilityRow(
              label: 'Voided at',
              value: _formatNullableDate(
                transaction.voidedAt,
                timezone: timezone,
              ),
            ),
            _AccountabilityRow(
              label: 'Void reason',
              value: transaction.voidReason ?? '-',
            ),
          ],

          const Gap(10),
          const Divider(height: 1, color: AppColors.border),
          const Gap(10),

          _AccountabilityRow(
            label: 'Last updated by',
            value: transaction.updatedByDisplayName,
          ),
          _AccountabilityRow(
            label: 'Last updated at',
            value: _formatNullableDate(
              transaction.updatedAt,
              timezone: timezone,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNullableDate(DateTime? value, {required String? timezone}) {
    if (value == null) {
      return '-';
    }

    return formatTransactionDate(value, timezone: timezone);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accent.withValues(alpha: 0.85)),
        const Gap(8),
        Text(
          title,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AccountabilityRow extends StatelessWidget {
  const _AccountabilityRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cleanValue = value.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 138,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Gap(10),
          Expanded(
            child: Text(
              cleanValue.isEmpty ? '-' : cleanValue,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
