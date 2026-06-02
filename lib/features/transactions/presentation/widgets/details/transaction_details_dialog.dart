import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_icons.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_state.dart';
import 'package:mina_system/features/transactions/presentation/functions/show_transaction_audit_history.dart';
import 'package:mina_system/features/transactions/presentation/widgets/details/transaction_accountability_section.dart';
import 'package:mina_system/features/transactions/presentation/widgets/details/transaction_approval_settlement_section.dart';
import 'package:mina_system/features/transactions/presentation/widgets/details/transaction_details_header.dart';
import 'package:mina_system/features/transactions/presentation/widgets/details/transaction_details_info_rows.dart';
import 'package:mina_system/features/transactions/presentation/widgets/details/transaction_note_section.dart';
import 'package:mina_system/features/transactions/presentation/widgets/details/transaction_proof_image_preview.dart';

class TransactionDetailsDialog extends StatelessWidget {
  const TransactionDetailsDialog({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final currentRole = context.currentUserRole;
    final canVoidTransaction = _canVoidTransaction(currentRole, transaction);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TransactionDetailsHeader(transaction: transaction),
        const Gap(20),
        TransactionDetailsInfoRows(transaction: transaction),
        TransactionApprovalSettlementSection(transaction: transaction),
        const Gap(16),
        TransactionAccountabilitySection(transaction: transaction),
        const Gap(12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                showTransactionAuditHistory(context, transaction: transaction);
              },
              icon: const Icon(AppIcons.auditHistory, size: 18),
              label: const Text('View Audit History'),
            ),
            if (canVoidTransaction)
              BlocBuilder<TransactionsCubit, TransactionsState>(
                builder: (context, state) {
                  final transactionId = transaction.id?.trim() ?? '';
                  final actionKey = 'transactions:void:$transactionId';
                  final isSubmitting = state.isActionSubmitting(actionKey);

                  return OutlinedButton.icon(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            _showVoidTransactionDialog(context);
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    icon: isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            AppIcons.cancelScheduleSendOutlined,
                            size: 18,
                          ),
                    label: Text(
                      isSubmitting ? 'Voiding...' : 'Void Transaction',
                    ),
                  );
                },
              ),
          ],
        ),
        const Gap(16),
        const SectionTitle(title: 'Photo'),
        const Gap(8),
        TransactionProofImagePreview(imagePath: transaction.imagePath ?? ''),
        const Gap(16),
        const SectionTitle(title: 'Note'),
        const Gap(8),
        TransactionNoteSection(note: transaction.note),
        const Gap(20),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ),
      ],
    );
  }

  bool _canVoidTransaction(String? role, TransactionModel transaction) {
    if (transaction.isVoided) {
      return false;
    }

    return CompanyRolePermissions.isOwner(role) ||
        CompanyRolePermissions.isAdmin(role) ||
        CompanyRolePermissions.isWarehouseManager(role);
  }

  Future<void> _showVoidTransactionDialog(BuildContext context) async {
    final reasonController = TextEditingController();

    final reason = await showDialog<String?>(
      context: context,
      builder: (dialogContext) {
        String? reasonError;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Void Transaction'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This will cancel ${transaction.transactionCode} and exclude it from custody balance calculations.',
                  ),
                  const Gap(12),
                  TextField(
                    controller: reasonController,
                    minLines: 3,
                    maxLines: 5,
                    onChanged: (_) {
                      if (reasonError == null) {
                        return;
                      }

                      setDialogState(() {
                        reasonError = null;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Void reason',
                      hintText:
                          'Example: Wrong quantity entered and will be recreated correctly',
                      errorText: reasonError,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final cleanReason = reasonController.text.trim();

                    if (cleanReason.length < 3) {
                      setDialogState(() {
                        reasonError =
                            'Void reason must be at least 3 characters.';
                      });
                      return;
                    }

                    Navigator.pop(dialogContext, cleanReason);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  child: const Text('Void Transaction'),
                ),
              ],
            );
          },
        );
      },
    );

    reasonController.dispose();

    if (reason == null || !context.mounted) {
      return;
    }

    final companyId = context.currentCompanyId;
    final success = await context.read<TransactionsCubit>().cancelTransaction(
      transaction: transaction,
      reason: reason,
      companyId: companyId,
    );

    if (!context.mounted || !success) {
      return;
    }

    AppMessage.showSuccess(context, 'Transaction voided successfully.');
    Navigator.pop(context);
  }
}
