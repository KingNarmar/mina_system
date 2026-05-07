import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/widgets/app_empty_state.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/functions/show_transaction_details.dart';
import 'package:mina_system/features/transactions/presentation/functions/transaction_type_helpers.dart';

class PendingApprovalsLayout extends StatelessWidget {
  const PendingApprovalsLayout({
    super.key,
    required this.transactions,
    required this.isMobile,
  });

  final List<TransactionModel> transactions;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return _PendingApprovalsMobileList(transactions: transactions);
    }

    return _PendingApprovalsDesktopTable(transactions: transactions);
  }
}

class _PendingApprovalsDesktopTable extends StatelessWidget {
  const _PendingApprovalsDesktopTable({required this.transactions});

  final List<TransactionModel> transactions;

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
              _PendingApprovalsHeader(count: transactions.length),
              const Gap(16),
              if (transactions.isEmpty)
                const AppEmptyState(
                  icon: Icons.verified_user_outlined,
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

class _PendingApprovalsMobileList extends StatelessWidget {
  const _PendingApprovalsMobileList({required this.transactions});

  final List<TransactionModel> transactions;

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
          return _PendingApprovalsHeader(count: transactions.length);
        }

        if (transactions.isEmpty) {
          return const AppEmptyState(
            icon: Icons.verified_user_outlined,
            title: 'No pending approvals',
            message:
                'Lost or damaged transactions that require approval or settlement will appear here.',
          );
        }

        final transaction = transactions[index - 1];

        return _PendingApprovalCard(transaction: transaction);
      },
    );
  }
}

class _PendingApprovalsHeader extends StatelessWidget {
  const _PendingApprovalsHeader({required this.count});

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
  const _PendingApprovalsTableRow({required this.transaction});

  final TransactionModel transaction;

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
                child: _StatusChip(
                  label: getTransactionTypeLabel(transaction.type),
                  color: getTransactionTypeColor(transaction.type),
                ),
              ),
            ),
            _BodyCell(
              value:
                  '${_formatQuantity(transaction.quantity)} ${transaction.unit}',
              flex: 1,
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _StatusChip(
                  label: _formatStatus(transaction.approvalStatus),
                  color: _getApprovalStatusColor(transaction.approvalStatus),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _StatusChip(
                  label: _formatStatus(transaction.settlementStatus),
                  color: _getSettlementStatusColor(
                    transaction.settlementStatus,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: _PendingApprovalActions(transaction: transaction),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingApprovalCard extends StatelessWidget {
  const _PendingApprovalCard({required this.transaction});

  final TransactionModel transaction;

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
                _StatusChip(
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
                  '${_formatQuantity(transaction.quantity)} ${transaction.unit}',
            ),
            const Gap(10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusChip(
                  label:
                      'Approval: ${_formatStatus(transaction.approvalStatus)}',
                  color: _getApprovalStatusColor(transaction.approvalStatus),
                ),
                _StatusChip(
                  label:
                      'Settlement: ${_formatStatus(transaction.settlementStatus)}',
                  color: _getSettlementStatusColor(
                    transaction.settlementStatus,
                  ),
                ),
              ],
            ),
            const Gap(12),
            _PendingApprovalActions(transaction: transaction),
          ],
        ),
      ),
    );
  }
}

class _PendingApprovalActions extends StatelessWidget {
  const _PendingApprovalActions({required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final hasApprovalDocument =
        transaction.approvalDocumentPath != null &&
        transaction.approvalDocumentPath!.trim().isNotEmpty;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: () {
            showTransactionDetails(context, transaction);
          },
          icon: const Icon(Icons.visibility_outlined, size: 18),
          label: const Text('View'),
        ),
        if (transaction.isApprovalPending)
          OutlinedButton.icon(
            onPressed: () {
              _pickAndUploadApprovalDocument(context, transaction);
            },
            icon: const Icon(Icons.upload_file_outlined, size: 18),
            label: Text(
              hasApprovalDocument ? 'Replace Signed' : 'Upload Signed',
            ),
          ),
        if (transaction.isApprovalPending)
          ElevatedButton.icon(
            onPressed: hasApprovalDocument
                ? () {
                    _approveTransaction(context, transaction);
                  }
                : null,
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Approve'),
          ),
        if (transaction.isApprovalPending)
          OutlinedButton.icon(
            onPressed: hasApprovalDocument
                ? () {
                    _rejectTransaction(context, transaction);
                  }
                : null,
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('Reject'),
          ),
        if (transaction.isApprovalApproved && transaction.isPendingSettlement)
          ElevatedButton.icon(
            onPressed: () {
              _settleTransaction(context, transaction);
            },
            icon: const Icon(Icons.price_check_outlined, size: 18),
            label: const Text('Settle'),
          ),
      ],
    );
  }

  Future<void> _pickAndUploadApprovalDocument(
    BuildContext context,
    TransactionModel transaction,
  ) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
      withData: false,
    );

    final path = result?.files.single.path;

    if (path == null || path.trim().isEmpty) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    final success = await context
        .read<TransactionsCubit>()
        .uploadApprovalDocument(
          transaction: transaction,
          localDocumentPath: path,
        );

    if (!context.mounted || !success) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signed approval document uploaded')),
    );
  }

  Future<void> _approveTransaction(
    BuildContext context,
    TransactionModel transaction,
  ) async {
    final confirmed = await _confirmAction(
      context: context,
      title: 'Approve Transaction',
      message:
          'Are you sure you want to approve this lost/damaged transaction?',
      confirmText: 'Approve',
    );

    if (!context.mounted || !confirmed) {
      return;
    }

    final success = await context.read<TransactionsCubit>().approveTransaction(
      transaction: transaction,
      decidedByProfileId: context.currentProfileId ?? '',
    );

    if (!context.mounted || !success) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Transaction approved')));
  }

  Future<void> _rejectTransaction(
    BuildContext context,
    TransactionModel transaction,
  ) async {
    final confirmed = await _confirmAction(
      context: context,
      title: 'Reject Transaction',
      message: 'Are you sure you want to reject this lost/damaged transaction?',
      confirmText: 'Reject',
    );

    if (!context.mounted || !confirmed) {
      return;
    }

    final success = await context.read<TransactionsCubit>().rejectTransaction(
      transaction: transaction,
      decidedByProfileId: context.currentProfileId ?? '',
    );

    if (!context.mounted || !success) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Transaction rejected')));
  }

  Future<void> _settleTransaction(
    BuildContext context,
    TransactionModel transaction,
  ) async {
    final confirmed = await _confirmAction(
      context: context,
      title: 'Settle Transaction',
      message:
          'Are you sure the deduction/settlement is completed for this transaction?',
      confirmText: 'Settle',
    );

    if (!context.mounted || !confirmed) {
      return;
    }

    final success = await context.read<TransactionsCubit>().settleTransaction(
      transaction: transaction,
      settledByProfileId: context.currentProfileId ?? '',
    );

    if (!context.mounted || !success) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Transaction settled')));
  }

  Future<bool> _confirmAction({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result ?? false;
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

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

String _formatQuantity(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }

  return value.toString();
}

Color _getApprovalStatusColor(String status) {
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

Color _getSettlementStatusColor(String status) {
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
