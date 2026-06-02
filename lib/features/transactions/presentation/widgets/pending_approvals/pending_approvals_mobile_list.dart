import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/app_empty_state.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_type_helpers.dart';
import 'package:mina_system/features/transactions/presentation/widgets/pending_approvals/pending_approval_actions.dart';
import 'package:mina_system/features/transactions/presentation/widgets/pending_approvals/pending_approval_status_chip.dart';
import 'package:mina_system/features/transactions/presentation/widgets/pending_approvals/pending_approvals_header.dart';
import 'package:mina_system/core/theme/app_icons.dart';

class PendingApprovalsMobileList extends StatelessWidget {
  const PendingApprovalsMobileList({
    super.key,
    required this.transactions,
    required this.canUploadApprovalDocument,
    required this.canApproveLostDamaged,
    required this.canRejectLostDamaged,
    required this.canSettleLostDamaged,
  });

  final List<TransactionModel> transactions;
  final bool canUploadApprovalDocument;
  final bool canApproveLostDamaged;
  final bool canRejectLostDamaged;
  final bool canSettleLostDamaged;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      itemCount: transactions.isEmpty ? 2 : transactions.length + 1,
      separatorBuilder: (context, index) {
        return const Gap(12);
      },
      itemBuilder: (context, index) {
        if (index == 0) {
          return PendingApprovalsHeader(count: transactions.length);
        }

        if (transactions.isEmpty) {
          return const AppEmptyState(
            icon: AppIcons.verifiedUser,
            title: 'No pending approvals',
            message:
                'Lost or damaged transactions that require approval or settlement will appear here.',
          );
        }

        final transaction = transactions[index - 1];

        return _PendingApprovalCard(
          transaction: transaction,
          canUploadApprovalDocument: canUploadApprovalDocument,
          canApproveLostDamaged: canApproveLostDamaged,
          canRejectLostDamaged: canRejectLostDamaged,
          canSettleLostDamaged: canSettleLostDamaged,
        );
      },
    );
  }
}

class _PendingApprovalCard extends StatelessWidget {
  const _PendingApprovalCard({
    required this.transaction,
    required this.canUploadApprovalDocument,
    required this.canApproveLostDamaged,
    required this.canRejectLostDamaged,
    required this.canSettleLostDamaged,
  });

  final TransactionModel transaction;
  final bool canUploadApprovalDocument;
  final bool canApproveLostDamaged;
  final bool canRejectLostDamaged;
  final bool canSettleLostDamaged;

  @override
  Widget build(BuildContext context) {
    final typeColor = getTransactionTypeColor(transaction.type);

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
                  backgroundColor: typeColor.withValues(alpha: 0.12),
                  child: Icon(getTransactionTypeIcon(transaction.type)),
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    transaction.transactionCode,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                PendingApprovalStatusChip(
                  label: getTransactionTypeLabel(transaction.type),
                  color: typeColor,
                ),
              ],
            ),
            const Gap(14),
            _InfoLine(
              label: 'Worker',
              value: '${transaction.workerName} (${transaction.workerHrCode})',
            ),
            _InfoLine(
              label: 'Tool',
              value: '${transaction.toolName} (${transaction.toolCode})',
            ),
            _InfoLine(
              label: 'Quantity',
              value:
                  '${formatPendingApprovalQuantity(transaction.quantity)} ${transaction.unit}',
            ),
            const Gap(10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                PendingApprovalStatusChip(
                  label:
                      'Approval: ${formatPendingApprovalStatus(transaction.approvalStatus)}',
                  color: getApprovalStatusColor(transaction.approvalStatus),
                ),
                PendingApprovalStatusChip(
                  label:
                      'Settlement: ${formatPendingApprovalStatus(transaction.settlementStatus)}',
                  color: getSettlementStatusColor(transaction.settlementStatus),
                ),
              ],
            ),
            const Gap(12),
            PendingApprovalActions(
              transaction: transaction,
              canUploadApprovalDocument: canUploadApprovalDocument,
              canApproveLostDamaged: canApproveLostDamaged,
              canRejectLostDamaged: canRejectLostDamaged,
              canSettleLostDamaged: canSettleLostDamaged,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
