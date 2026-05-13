import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/format_transaction_date.dart';
import 'package:mina_system/features/transactions/presentation/widgets/details/transaction_details_info_rows.dart';
import 'package:mina_system/features/transactions/presentation/widgets/details/transaction_signed_document_button.dart';

class TransactionApprovalSettlementSection extends StatelessWidget {
  const TransactionApprovalSettlementSection({
    super.key,
    required this.transaction,
  });

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    if (!transaction.isLostOrDamaged) {
      return const SizedBox.shrink();
    }

    final hasApprovalDocument =
        transaction.approvalDocumentPath != null &&
        transaction.approvalDocumentPath!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(10),
        const SectionTitle(title: 'Approval & Settlement'),
        const Gap(8),
        TransactionDetailsRow(
          label: 'Approval',
          value: _formatStatus(transaction.approvalStatus),
        ),
        TransactionDetailsRow(
          label: 'Settlement',
          value: _formatStatus(transaction.settlementStatus),
        ),
        TransactionDetailsRow(
          label: 'Document',
          value: hasApprovalDocument
              ? 'Signed document uploaded'
              : 'No signed document uploaded',
        ),
        if (hasApprovalDocument) ...[
          const Gap(4),
          TransactionSignedDocumentButton(transaction: transaction),
          const Gap(8),
        ],
        if (_hasText(transaction.approvalDecisionNote))
          TransactionDetailsRow(
            label: 'Decision',
            value: transaction.approvalDecisionNote!,
          ),
        if (transaction.approvalDecidedAt != null)
          TransactionDetailsRow(
            label: 'Decided At',
            value: formatTransactionDate(
              transaction.approvalDecidedAt!,
              timezone: context.currentCompany?.timezone,
            ),
          ),
        if (_hasText(transaction.settlementNote))
          TransactionDetailsRow(
            label: 'Settlement Note',
            value: transaction.settlementNote!,
          ),
        if (transaction.settledAt != null)
          TransactionDetailsRow(
            label: 'Settled At',
            value: formatTransactionDate(
              transaction.settledAt!,
              timezone: context.currentCompany?.timezone,
            ),
          ),
      ],
    );
  }

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  String _formatStatus(String value) {
    return value
        .trim()
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) {
          return '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}';
        })
        .join(' ');
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.body.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
