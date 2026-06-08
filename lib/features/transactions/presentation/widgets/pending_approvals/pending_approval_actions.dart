import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mina_system/core/theme/app_icons.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_state.dart';
import 'package:mina_system/features/transactions/presentation/functions/show_transaction_details.dart';
import 'package:mina_system/features/transactions/presentation/widgets/details/transaction_signed_document_button.dart';

part 'pending_approval_document_picker.dart';
part 'pending_approval_ui_helpers.dart';
part 'pending_approval_workflow.dart';

class PendingApprovalActions extends StatelessWidget {
  const PendingApprovalActions({
    super.key,
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
    final hasApprovalDocument =
        transaction.approvalDocumentPath != null &&
        transaction.approvalDocumentPath!.trim().isNotEmpty;

    final isSubmitting = context.select<TransactionsCubit, bool>((cubit) {
      return cubit.state.isSubmitting;
    });

    final isUploadingApprovalDocument = context.select<TransactionsCubit, bool>(
      (cubit) {
        return cubit.state.isActionSubmitting(
          TransactionsSubmissionKeys.uploadApprovalDocument(transaction),
        );
      },
    );

    final isApproving = context.select<TransactionsCubit, bool>((cubit) {
      return cubit.state.isActionSubmitting(
        TransactionsSubmissionKeys.approve(transaction),
      );
    });

    final isRejecting = context.select<TransactionsCubit, bool>((cubit) {
      return cubit.state.isActionSubmitting(
        TransactionsSubmissionKeys.reject(transaction),
      );
    });

    final isSettling = context.select<TransactionsCubit, bool>((cubit) {
      return cubit.state.isActionSubmitting(
        TransactionsSubmissionKeys.settle(transaction),
      );
    });

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: () {
            showTransactionDetails(context, transaction);
          },
          icon: const Icon(AppIcons.view, size: 18),
          label: const Text('View'),
        ),
        if (hasApprovalDocument)
          TransactionSignedDocumentButton(
            transaction: transaction,
            compact: true,
            label: 'View Signed',
          ),
        if (transaction.isApprovalPending && canUploadApprovalDocument)
          OutlinedButton.icon(
            onPressed: isSubmitting
                ? null
                : () {
                    _pickAndUploadApprovalDocument(context, transaction);
                  },
            icon: isUploadingApprovalDocument
                ? const _ActionButtonLoader()
                : const Icon(AppIcons.upload, size: 18),
            label: Text(
              isUploadingApprovalDocument
                  ? 'Uploading...'
                  : hasApprovalDocument
                  ? 'Replace Signed'
                  : 'Upload Signed',
            ),
          ),
        if (transaction.isApprovalPending && canApproveLostDamaged)
          ElevatedButton.icon(
            onPressed: hasApprovalDocument && !isSubmitting
                ? () {
                    _approveTransaction(context, transaction);
                  }
                : null,
            icon: isApproving
                ? const _ActionButtonLoader()
                : const Icon(AppIcons.approve, size: 18),
            label: Text(isApproving ? 'Approving...' : 'Approve'),
          ),
        if (transaction.isApprovalPending && canRejectLostDamaged)
          OutlinedButton.icon(
            onPressed: hasApprovalDocument && !isSubmitting
                ? () {
                    _rejectTransaction(context, transaction);
                  }
                : null,
            icon: isRejecting
                ? const _ActionButtonLoader()
                : const Icon(AppIcons.reject, size: 18),
            label: Text(isRejecting ? 'Rejecting...' : 'Reject'),
          ),
        if (transaction.isApprovalApproved &&
            transaction.isPendingSettlement &&
            canSettleLostDamaged)
          ElevatedButton.icon(
            onPressed: isSubmitting
                ? null
                : () {
                    _settleTransaction(context, transaction);
                  },
            icon: isSettling
                ? const _ActionButtonLoader()
                : const Icon(AppIcons.settle, size: 18),
            label: Text(isSettling ? 'Settling...' : 'Settle'),
          ),
      ],
    );
  }
}
