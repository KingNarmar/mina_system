import 'package:flutter/material.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/audit_logs/presentation/widgets/audit_history_bottom_sheet.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';

void showLookupAuditHistory(
  BuildContext context, {
  required String entityType,
  required String entityId,
  required String title,
  String? timezone,
  String? dateFormat,
}) {
  final companyId = context.currentCompanyId;
  final cleanEntityType = entityType.trim();
  final cleanEntityId = entityId.trim();

  if (companyId == null || companyId.trim().isEmpty) {
    AppMessage.showError(
      context,
      'Current company was not found. Please refresh and try again.',
    );
    return;
  }

  if (cleanEntityType.isEmpty) {
    AppMessage.showError(
      context,
      'Audit entity type was not found. Please refresh and try again.',
    );
    return;
  }

  if (cleanEntityId.isEmpty) {
    AppMessage.showError(
      context,
      'Selected lookup record was not found. Please refresh and try again.',
    );
    return;
  }

  showAuditHistoryBottomSheet(
    context: context,
    companyId: companyId,
    entityType: cleanEntityType,
    entityId: cleanEntityId,
    title: title,
    timezone: timezone ?? context.currentCompany?.timezone,
    dateFormat: dateFormat,
  );
}
