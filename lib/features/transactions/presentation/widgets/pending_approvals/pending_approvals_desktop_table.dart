import 'dart:math' as math;

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

class PendingApprovalsDesktopTable extends StatelessWidget {
  const PendingApprovalsDesktopTable({
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = math.max(constraints.maxWidth, 1180.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PendingApprovalsHeader(count: transactions.length),
              const Gap(16),
              if (transactions.isEmpty)
                const AppEmptyState(
                  icon: AppIcons.verifiedUser,
                  title: 'No pending approvals',
                  message:
                      'Lost or damaged transactions that require approval or settlement will appear here.',
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: Card(
                      elevation: 0,
                      color: AppColors.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          const _PendingApprovalsTableHeader(),
                          const Divider(height: 1, color: AppColors.border),
                          ...transactions.map((transaction) {
                            return _PendingApprovalsTableRow(
                              transaction: transaction,
                              canUploadApprovalDocument:
                                  canUploadApprovalDocument,
                              canApproveLostDamaged: canApproveLostDamaged,
                              canRejectLostDamaged: canRejectLostDamaged,
                              canSettleLostDamaged: canSettleLostDamaged,
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PendingApprovalsTableHeader extends StatelessWidget {
  const _PendingApprovalsTableHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _HeaderCell(label: 'Code', flex: 2),
          _HeaderCell(label: 'Worker', flex: 3),
          _HeaderCell(label: 'Tool', flex: 3),
          _HeaderCell(label: 'Type', flex: 2),
          _HeaderCell(label: 'Qty', flex: 1),
          _HeaderCell(label: 'Approval', flex: 2),
          _HeaderCell(label: 'Settlement', flex: 2),
          _HeaderCell(label: 'Actions', flex: 4),
        ],
      ),
    );
  }
}

class _PendingApprovalsTableRow extends StatelessWidget {
  const _PendingApprovalsTableRow({
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
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _BodyCell(value: transaction.transactionCode, flex: 2),
            _BodyCell(
              value: '${transaction.workerName}\n${transaction.workerHrCode}',
              flex: 3,
            ),
            _BodyCell(
              value: '${transaction.toolName}\n${transaction.toolCode}',
              flex: 3,
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: PendingApprovalStatusChip(
                  label: getTransactionTypeLabel(transaction.type),
                  color: getTransactionTypeColor(transaction.type),
                ),
              ),
            ),
            _BodyCell(
              value:
                  '${formatPendingApprovalQuantity(transaction.quantity)} ${transaction.unit}',
              flex: 1,
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: PendingApprovalStatusChip(
                  label: formatPendingApprovalStatus(
                    transaction.approvalStatus,
                  ),
                  color: getApprovalStatusColor(transaction.approvalStatus),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: PendingApprovalStatusChip(
                  label: formatPendingApprovalStatus(
                    transaction.settlementStatus,
                  ),
                  color: getSettlementStatusColor(transaction.settlementStatus),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: PendingApprovalActions(
                transaction: transaction,
                canUploadApprovalDocument: canUploadApprovalDocument,
                canApproveLostDamaged: canApproveLostDamaged,
                canRejectLostDamaged: canRejectLostDamaged,
                canSettleLostDamaged: canSettleLostDamaged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.label, required this.flex});

  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell({required this.value, required this.flex});

  final String value;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        value,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
