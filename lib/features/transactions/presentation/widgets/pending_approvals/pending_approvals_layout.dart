import 'package:flutter/material.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/widgets/pending_approvals/pending_approvals_desktop_table.dart';
import 'package:mina_system/features/transactions/presentation/widgets/pending_approvals/pending_approvals_mobile_list.dart';

class PendingApprovalsLayout extends StatelessWidget {
  const PendingApprovalsLayout({
    super.key,
    required this.transactions,
    required this.isMobile,
    required this.canUploadApprovalDocument,
    required this.canApproveLostDamaged,
    required this.canRejectLostDamaged,
    required this.canSettleLostDamaged,
  });

  final List<TransactionModel> transactions;
  final bool isMobile;
  final bool canUploadApprovalDocument;
  final bool canApproveLostDamaged;
  final bool canRejectLostDamaged;
  final bool canSettleLostDamaged;

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return PendingApprovalsMobileList(
        transactions: transactions,
        canUploadApprovalDocument: canUploadApprovalDocument,
        canApproveLostDamaged: canApproveLostDamaged,
        canRejectLostDamaged: canRejectLostDamaged,
        canSettleLostDamaged: canSettleLostDamaged,
      );
    }

    return PendingApprovalsDesktopTable(
      transactions: transactions,
      canUploadApprovalDocument: canUploadApprovalDocument,
      canApproveLostDamaged: canApproveLostDamaged,
      canRejectLostDamaged: canRejectLostDamaged,
      canSettleLostDamaged: canSettleLostDamaged,
    );
  }
}
