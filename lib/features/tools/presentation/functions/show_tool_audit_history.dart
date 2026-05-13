import 'package:flutter/material.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/audit_logs/presentation/widgets/audit_history_bottom_sheet.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/tools/data/models/tool_model.dart';

void showToolAuditHistory(BuildContext context, {required ToolModel tool}) {
  final companyId = context.currentCompanyId;
  final toolId = tool.id?.trim();

  if (companyId == null || companyId.trim().isEmpty) {
    AppMessage.showError(
      context,
      'Current company was not found. Please refresh and try again.',
    );
    return;
  }

  if (toolId == null || toolId.isEmpty) {
    AppMessage.showError(
      context,
      'Tool record was not found. Please refresh and try again.',
    );
    return;
  }

  showAuditHistoryBottomSheet(
    context: context,
    companyId: companyId,
    entityType: 'tool',
    entityId: toolId,
    title: 'Tool Audit History',
    timezone: context.currentCompany?.timezone,
  );
}
