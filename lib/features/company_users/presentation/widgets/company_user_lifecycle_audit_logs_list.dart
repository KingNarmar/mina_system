import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/core/utils/company_date_time_formatter.dart';
import 'package:mina_system/features/audit_logs/data/models/audit_log_model.dart';
import 'package:mina_system/core/theme/app_icons.dart';

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
    if (auditLogs.isEmpty) {
      return const _TeamActivityEmptyState();
    }

    return Column(
      children: List.generate(auditLogs.length, (index) {
        return _TeamActivityTimelineTile(
          auditLog: auditLogs[index],
          companyTimezone: companyTimezone,
          isLast: index == auditLogs.length - 1,
        );
      }),
    );
  }
}

class _TeamActivityTimelineTile extends StatelessWidget {
  const _TeamActivityTimelineTile({
    required this.auditLog,
    required this.companyTimezone,
    required this.isLast,
  });

  final AuditLogModel auditLog;
  final String? companyTimezone;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final config = _activityConfigForAction(auditLog.action);

    final createdAtText = CompanyDateTimeFormatter.formatNullableDateTime(
      auditLog.createdAt,
      timezone: companyTimezone,
      includeTimezone: true,
      fallback: 'Unknown date',
    );

    final details = _buildDetails();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 42,
            child: Column(
              children: [
                _TimelineMarker(config: config),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Gap(10),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ActivityHeader(
                    title: config.title,
                    createdAtText: createdAtText,
                  ),
                  const Gap(14),
                  _ActivityInfoPanel(
                    actor: _actorDisplayName(auditLog),
                    target: _targetDisplayName(auditLog),
                  ),
                  if (details.isNotEmpty) ...[
                    const Gap(12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: details.map((detail) {
                        return _ActivityDetailPill(
                          label: detail.label,
                          value: detail.value,
                          color: detail.color,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_ActivityDetail> _buildDetails() {
    switch (auditLog.action.trim().toLowerCase()) {
      case 'company_user_invited':
        return [
          _ActivityDetail(
            label: 'Role',
            value: _roleLabel(_stringFromMap(auditLog.newData, 'role')),
            color: AppColors.accent,
          ),
          _ActivityDetail(
            label: 'Status',
            value: _statusLabel(_stringFromMap(auditLog.newData, 'status')),
            color: AppColors.textSecondary,
          ),
        ];

      case 'company_invitation_accepted':
        return [
          _ActivityDetail(
            label: 'Role',
            value: _roleLabel(
              _stringFromMap(auditLog.newData, 'role') ??
                  _stringFromMap(auditLog.oldData, 'role'),
            ),
            color: AppColors.accent,
          ),
          const _ActivityDetail(
            label: 'From',
            value: 'Pending',
            color: AppColors.warning,
          ),
          const _ActivityDetail(
            label: 'To',
            value: 'Accepted',
            color: AppColors.success,
          ),
        ];

      case 'company_invitation_cancelled':
        return [
          _ActivityDetail(
            label: 'Role',
            value: _roleLabel(
              _stringFromMap(auditLog.newData, 'role') ??
                  _stringFromMap(auditLog.oldData, 'role'),
            ),
            color: AppColors.accent,
          ),
          const _ActivityDetail(
            label: 'From',
            value: 'Pending',
            color: AppColors.accent,
          ),
          const _ActivityDetail(
            label: 'To',
            value: 'Cancelled',
            color: AppColors.warning,
          ),
        ];

      case 'company_member_role_changed':
        return [
          _ActivityDetail(
            label: 'Old role',
            value: _roleLabel(_oldRole(auditLog)),
            color: AppColors.textSecondary,
          ),
          _ActivityDetail(
            label: 'New role',
            value: _roleLabel(_newRole(auditLog)),
            color: AppColors.accent,
          ),
        ];

      case 'company_member_deactivated':
        return [
          _ActivityDetail(
            label: 'Role',
            value: _roleLabel(
              _stringFromMap(auditLog.newData, 'role') ??
                  _stringFromMap(auditLog.oldData, 'role'),
            ),
            color: AppColors.accent,
          ),
          const _ActivityDetail(
            label: 'From',
            value: 'Active',
            color: AppColors.success,
          ),
          const _ActivityDetail(
            label: 'To',
            value: 'Inactive',
            color: AppColors.warning,
          ),
        ];

      case 'company_member_reactivated':
        return [
          _ActivityDetail(
            label: 'Role',
            value: _roleLabel(
              _stringFromMap(auditLog.newData, 'role') ??
                  _stringFromMap(auditLog.oldData, 'role'),
            ),
            color: AppColors.accent,
          ),
          const _ActivityDetail(
            label: 'From',
            value: 'Inactive',
            color: AppColors.warning,
          ),
          const _ActivityDetail(
            label: 'To',
            value: 'Active',
            color: AppColors.success,
          ),
        ];

      default:
        return const [];
    }
  }

  _ActivityConfig _activityConfigForAction(String action) {
    switch (action.trim().toLowerCase()) {
      case 'company_user_invited':
        return const _ActivityConfig(
          title: 'Invitation Sent',
          icon: AppIcons.personAddAltOutlined,
          color: AppColors.accent,
        );
      case 'company_invitation_accepted':
        return const _ActivityConfig(
          title: 'Invitation Accepted',
          icon: AppIcons.markEmailReadOutlined,
          color: AppColors.success,
        );
      case 'company_invitation_cancelled':
        return const _ActivityConfig(
          title: 'Invitation Cancelled',
          icon: AppIcons.cancelScheduleSendOutlined,
          color: AppColors.warning,
        );
      case 'company_member_role_changed':
        return const _ActivityConfig(
          title: 'Member Role Changed',
          icon: AppIcons.manageAccountsOutlined,
          color: AppColors.accent,
        );
      case 'company_member_deactivated':
        return const _ActivityConfig(
          title: 'Member Deactivated',
          icon: AppIcons.personOffOutlined,
          color: AppColors.warning,
        );
      case 'company_member_reactivated':
        return const _ActivityConfig(
          title: 'Member Reactivated',
          icon: AppIcons.personAddAlt1Outlined,
          color: AppColors.success,
        );
      default:
        return _ActivityConfig(
          title: _toTitleCase(action),
          icon: AppIcons.historyOutlined,
          color: AppColors.textSecondary,
        );
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

class _TimelineMarker extends StatelessWidget {
  const _TimelineMarker({required this.config});

  final _ActivityConfig config;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: config.color.withValues(alpha: 0.16)),
      ),
      child: Icon(config.icon, color: config.color, size: 22),
    );
  }
}

class _ActivityHeader extends StatelessWidget {
  const _ActivityHeader({required this.title, required this.createdAtText});

  final String title;
  final String createdAtText;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const Gap(12),
        Flexible(
          child: Text(
            createdAtText,
            textAlign: TextAlign.right,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityInfoPanel extends StatelessWidget {
  const _ActivityInfoPanel({required this.actor, required this.target});

  final String actor;
  final String target;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _ActivityInfoLine(
            icon: AppIcons.worker,
            label: 'Actor',
            value: actor,
          ),
          const Gap(10),
          _ActivityInfoLine(
            icon: AppIcons.adjustOutlined,
            label: 'Target',
            value: target,
          ),
        ],
      ),
    );
  }
}

class _ActivityInfoLine extends StatelessWidget {
  const _ActivityInfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: AppColors.textSecondary),
        const Gap(8),
        SizedBox(
          width: 54,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Gap(8),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityDetailPill extends StatelessWidget {
  const _ActivityDetailPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.caption,
          children: [
            TextSpan(
              text: '$label: ',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            TextSpan(
              text: value,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamActivityEmptyState extends StatelessWidget {
  const _TeamActivityEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              AppIcons.historyOutlined,
              color: AppColors.accent,
              size: 28,
            ),
          ),
          const Gap(12),
          Text(
            'No team activity yet',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(6),
          Text(
            'Invitation, role, and access lifecycle events will appear here.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityConfig {
  const _ActivityConfig({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;
}

class _ActivityDetail {
  const _ActivityDetail({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;
}
