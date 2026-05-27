import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/utils/company_date_time_formatter.dart';
import 'package:mina_system/features/audit_logs/data/models/audit_log_model.dart';

class CompanyUserLifecycleAuditLogsList extends StatelessWidget {
  const CompanyUserLifecycleAuditLogsList({
    super.key,
    required this.auditLogs,
    this.companyTimezone,
  });

  final List<AuditLogModel> auditLogs;
  final String? companyTimezone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Team Activity', style: AppTextStyles.title),
        const Gap(6),
        const Text(
          'Trusted lifecycle history for invitations, role changes, and member access changes.',
          style: AppTextStyles.body,
        ),
        const Gap(12),
        if (auditLogs.isEmpty)
          const Text(
            'No company-user lifecycle activity found yet.',
            style: AppTextStyles.body,
          )
        else
          Column(
            children: auditLogs.map((auditLog) {
              return _CompanyUserLifecycleAuditLogTile(
                auditLog: auditLog,
                companyTimezone: companyTimezone,
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _CompanyUserLifecycleAuditLogTile extends StatelessWidget {
  const _CompanyUserLifecycleAuditLogTile({
    required this.auditLog,
    required this.companyTimezone,
  });

  final AuditLogModel auditLog;
  final String? companyTimezone;

  @override
  Widget build(BuildContext context) {
    final createdAtText = CompanyDateTimeFormatter.formatNullableDateTime(
      auditLog.createdAt,
      timezone: companyTimezone,
      includeTimezone: true,
      fallback: 'Unknown date',
    );

    final details = _buildDetails();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CompanyUserLifecycleAuditHeader(
            icon: _iconForAction(auditLog.action),
            title: _titleForAction(auditLog.action),
            createdAtText: createdAtText,
          ),
          const Gap(12),
          _AuditDetailLine(label: 'Actor', value: _actorDisplayName(auditLog)),
          const Gap(6),
          _AuditDetailLine(
            label: 'Target',
            value: _targetDisplayName(auditLog),
          ),
          if (details.isNotEmpty) ...[
            const Gap(10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: details.map((detail) {
                return _AuditDetailPill(
                  label: detail.label,
                  value: detail.value,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  List<_AuditDetail> _buildDetails() {
    switch (auditLog.action.trim().toLowerCase()) {
      case 'company_user_invited':
        return [
          _AuditDetail(
            label: 'Role',
            value: _roleLabel(_stringFromMap(auditLog.newData, 'role')),
          ),
          _AuditDetail(
            label: 'Status',
            value: _statusLabel(_stringFromMap(auditLog.newData, 'status')),
          ),
        ];

      case 'company_invitation_accepted':
        return [
          _AuditDetail(
            label: 'Role',
            value: _roleLabel(
              _stringFromMap(auditLog.newData, 'role') ??
                  _stringFromMap(auditLog.oldData, 'role'),
            ),
          ),
          const _AuditDetail(label: 'From', value: 'Pending'),
          const _AuditDetail(label: 'To', value: 'Accepted'),
        ];

      case 'company_invitation_cancelled':
        return [
          _AuditDetail(
            label: 'Role',
            value: _roleLabel(
              _stringFromMap(auditLog.newData, 'role') ??
                  _stringFromMap(auditLog.oldData, 'role'),
            ),
          ),
          const _AuditDetail(label: 'From', value: 'Pending'),
          const _AuditDetail(label: 'To', value: 'Cancelled'),
        ];

      case 'company_member_role_changed':
        return [
          _AuditDetail(
            label: 'Old role',
            value: _roleLabel(_oldRole(auditLog)),
          ),
          _AuditDetail(
            label: 'New role',
            value: _roleLabel(_newRole(auditLog)),
          ),
        ];

      case 'company_member_deactivated':
        return [
          _AuditDetail(
            label: 'Role',
            value: _roleLabel(
              _stringFromMap(auditLog.newData, 'role') ??
                  _stringFromMap(auditLog.oldData, 'role'),
            ),
          ),
          const _AuditDetail(label: 'From', value: 'Active'),
          const _AuditDetail(label: 'To', value: 'Inactive'),
        ];

      case 'company_member_reactivated':
        return [
          _AuditDetail(
            label: 'Role',
            value: _roleLabel(
              _stringFromMap(auditLog.newData, 'role') ??
                  _stringFromMap(auditLog.oldData, 'role'),
            ),
          ),
          const _AuditDetail(label: 'From', value: 'Inactive'),
          const _AuditDetail(label: 'To', value: 'Active'),
        ];

      default:
        return const [];
    }
  }

  IconData _iconForAction(String action) {
    switch (action.trim().toLowerCase()) {
      case 'company_user_invited':
        return Icons.person_add_alt_outlined;
      case 'company_invitation_accepted':
        return Icons.mark_email_read_outlined;
      case 'company_invitation_cancelled':
        return Icons.cancel_schedule_send_outlined;
      case 'company_member_role_changed':
        return Icons.manage_accounts_outlined;
      case 'company_member_deactivated':
        return Icons.person_off_outlined;
      case 'company_member_reactivated':
        return Icons.person_add_alt_1_outlined;
      default:
        return Icons.history_outlined;
    }
  }

  String _titleForAction(String action) {
    switch (action.trim().toLowerCase()) {
      case 'company_user_invited':
        return 'Invitation Sent';
      case 'company_invitation_accepted':
        return 'Invitation Accepted';
      case 'company_invitation_cancelled':
        return 'Invitation Cancelled';
      case 'company_member_role_changed':
        return 'Member Role Changed';
      case 'company_member_deactivated':
        return 'Member Deactivated';
      case 'company_member_reactivated':
        return 'Member Reactivated';
      default:
        return _toTitleCase(action);
    }
  }

  String _actorDisplayName(AuditLogModel auditLog) {
    final name = _cleanDisplayValue(auditLog.actorNameSnapshot);
    final email = _cleanDisplayValue(auditLog.actorEmailSnapshot);

    if (name != null && email != null) {
      return '$name ($email)';
    }

    if (name != null) {
      return name;
    }

    if (email != null) {
      return email;
    }

    return 'Recorded actor';
  }

  String _targetDisplayName(AuditLogModel auditLog) {
    final action = auditLog.action.trim().toLowerCase();

    if (action.startsWith('company_invitation') ||
        action == 'company_user_invited') {
      final email =
          _cleanDisplayValue(_stringFromMap(auditLog.newData, 'email')) ??
          _cleanDisplayValue(_stringFromMap(auditLog.oldData, 'email')) ??
          _cleanDisplayValue(auditLog.entityLabelSnapshot);

      return email ?? 'Recorded invitation';
    }

    final name =
        _cleanDisplayValue(_stringFromMap(auditLog.newData, 'full_name')) ??
        _cleanDisplayValue(_stringFromMap(auditLog.oldData, 'full_name'));

    final email =
        _cleanDisplayValue(_stringFromMap(auditLog.newData, 'email')) ??
        _cleanDisplayValue(_stringFromMap(auditLog.oldData, 'email')) ??
        _cleanDisplayValue(auditLog.entityLabelSnapshot);

    if (name != null && email != null) {
      return '$name ($email)';
    }

    if (name != null) {
      return name;
    }

    if (email != null) {
      return email;
    }

    return 'Recorded member';
  }

  String? _oldRole(AuditLogModel auditLog) {
    return _stringFromMap(auditLog.metadata, 'old_role') ??
        _stringFromMap(auditLog.oldData, 'role');
  }

  String? _newRole(AuditLogModel auditLog) {
    return _stringFromMap(auditLog.metadata, 'new_role') ??
        _stringFromMap(auditLog.newData, 'role');
  }

  String _roleLabel(String? role) {
    final cleanRole = role?.trim();

    if (cleanRole == null || cleanRole.isEmpty) {
      return 'Not recorded';
    }

    if (CompanyRoles.isKnownRole(cleanRole)) {
      return CompanyRoles.label(cleanRole);
    }

    return _toTitleCase(cleanRole);
  }

  String _statusLabel(String? status) {
    final cleanStatus = status?.trim();

    if (cleanStatus == null || cleanStatus.isEmpty) {
      return 'Not recorded';
    }

    return _toTitleCase(cleanStatus);
  }

  String? _stringFromMap(Map<String, dynamic>? data, String key) {
    if (data == null || data.isEmpty) {
      return null;
    }

    final value = data[key];

    if (value == null) {
      return null;
    }

    final cleanValue = value.toString().trim();

    if (cleanValue.isEmpty) {
      return null;
    }

    return cleanValue;
  }

  String? _cleanDisplayValue(String? value) {
    final cleanValue = value?.trim();

    if (cleanValue == null || cleanValue.isEmpty) {
      return null;
    }

    if (_looksLikeUuid(cleanValue)) {
      return null;
    }

    return cleanValue;
  }

  bool _looksLikeUuid(String value) {
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(value.trim());
  }

  String _toTitleCase(String value) {
    final cleanValue = value.trim().replaceAll('_', ' ');

    if (cleanValue.isEmpty) {
      return 'Unknown';
    }

    return cleanValue
        .split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .map((word) {
          final cleanWord = word.trim().toLowerCase();

          if (cleanWord.length == 1) {
            return cleanWord.toUpperCase();
          }

          return '${cleanWord[0].toUpperCase()}${cleanWord.substring(1)}';
        })
        .join(' ');
  }
}

class _CompanyUserLifecycleAuditHeader extends StatelessWidget {
  const _CompanyUserLifecycleAuditHeader({
    required this.icon,
    required this.title,
    required this.createdAtText,
  });

  final IconData icon;
  final String title;
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
          child: Icon(icon, color: AppColors.accent, size: 20),
        ),
        const Gap(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Gap(2),
              Text(
                createdAtText,
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

class _AuditDetailLine extends StatelessWidget {
  const _AuditDetailLine({required this.label, required this.value});

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
            style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _AuditDetailPill extends StatelessWidget {
  const _AuditDetailPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.caption,
          children: [
            TextSpan(
              text: '$label: ',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            TextSpan(
              text: value,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuditDetail {
  const _AuditDetail({required this.label, required this.value});

  final String label;
  final String value;
}
