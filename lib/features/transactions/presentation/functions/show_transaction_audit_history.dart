import 'package:flutter/material.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/audit_logs/presentation/widgets/audit_history_bottom_sheet.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';

void showTransactionAuditHistory(
  BuildContext context, {
  required TransactionModel transaction,
}) {
  final companyId = context.currentCompanyId;
  final transactionId = transaction.id?.trim();

  if (companyId == null || companyId.trim().isEmpty) {
    AppMessage.showError(
      context,
      'Current company was not found. Please refresh and try again.',
    );
    return;
  }

  if (transactionId == null || transactionId.isEmpty) {
    AppMessage.showError(
      context,
      'Transaction record was not found. Please refresh and try again.',
    );
    return;
  }

  showAuditHistoryBottomSheet(
    context: context,
    companyId: companyId,
    entityType: 'transaction',
    entityId: transactionId,
    title: 'Transaction Audit History',
    timezone: context.currentCompany?.timezone,
  );
}
