import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/utils/company_date_time_formatter.dart';
import 'package:mina_system/features/audit_logs/data/models/audit_log_model.dart';
import 'package:mina_system/features/audit_logs/data/services/audit_log_lookup_resolver.dart';
import 'package:mina_system/features/audit_logs/presentation/widgets/audit_log_data_change_section.dart';

class AuditLogTile extends StatelessWidget {
  const AuditLogTile({
    super.key,
    required this.auditLog,
    this.lookupResolver = AuditLogLookupResolver.empty,
    this.timezone,
    this.dateFormat,
  });

  final AuditLogModel auditLog;
  final AuditLogLookupResolver lookupResolver;
  final String? timezone;
  final String? dateFormat;

  @override
  Widget build(BuildContext context) {
    final createdAtText = CompanyDateTimeFormatter.formatNullableDateTime(
      auditLog.createdAt,
      timezone: timezone,
      dateFormat: dateFormat,
      fallback: 'Unknown date',
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlayDark.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AuditLogHeader(auditLog: auditLog, createdAtText: createdAtText),
          const SizedBox(height: 12),
          _AuditInfoLine(label: 'Actor', value: auditLog.actorDisplayName),
          const SizedBox(height: 6),
          _AuditInfoLine(label: 'Record', value: auditLog.entityDisplayLabel),
          const SizedBox(height: 12),
          AuditLogDataChangeSection(
            oldData: auditLog.oldData,
            newData: auditLog.newData,
            lookupResolver: lookupResolver,
          ),
        ],
      ),
    );
  }
}

class _AuditLogHeader extends StatelessWidget {
  const _AuditLogHeader({
    required this.auditLog,
    required this.createdAtText,
  });

  final AuditLogModel auditLog;
  final String createdAtText;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.history_rounded,
            color: AppColors.accent,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                auditLog.actionLabel,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${auditLog.entityTypeLabel} • $createdAtText',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuditInfoLine extends StatelessWidget {
  const _AuditInfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}