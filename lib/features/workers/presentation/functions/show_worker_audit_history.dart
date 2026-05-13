import 'package:flutter/material.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/audit_logs/presentation/widgets/audit_history_bottom_sheet.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';

void showWorkerAuditHistory(
  BuildContext context, {
  required WorkerModel worker,
}) {
  final companyId = context.currentCompanyId;
  final workerId = worker.id?.trim();

  if (companyId == null || companyId.trim().isEmpty) {
    AppMessage.showError(
      context,
      'Current company was not found. Please refresh and try again.',
    );
    return;
  }

  if (workerId == null || workerId.isEmpty) {
    AppMessage.showError(
      context,
      'Worker record was not found. Please refresh and try again.',
    );
    return;
  }

  showAuditHistoryBottomSheet(
    context: context,
    companyId: companyId,
    entityType: 'worker',
    entityId: workerId,
    title: 'Worker Audit History',
    timezone: context.currentCompany?.timezone,
  );
}
