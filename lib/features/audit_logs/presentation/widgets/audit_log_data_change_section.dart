import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/audit_logs/data/services/audit_log_lookup_resolver.dart';

class AuditLogDataChangeSection extends StatelessWidget {
  const AuditLogDataChangeSection({
    super.key,
    required this.oldData,
    required this.newData,
    this.lookupResolver = AuditLogLookupResolver.empty,
  });

  final Map<String, dynamic>? oldData;
  final Map<String, dynamic>? newData;
  final AuditLogLookupResolver lookupResolver;

  @override
  Widget build(BuildContext context) {
    final changeRows = _buildChangeRows();

    if (changeRows.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          'No detailed data changes available.',
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Changes',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...changeRows,
      ],
    );
  }

  List<Widget> _buildChangeRows() {
    if (oldData == null && newData == null) {
      return [];
    }

    if (oldData == null && newData != null) {
      return _buildCreatedRows(newData!);
    }

    if (oldData != null && newData == null) {
      return _buildRemovedRows(oldData!);
    }

    return _buildUpdatedRows(oldData!, newData!);
  }

  List<Widget> _buildCreatedRows(Map<String, dynamic> data) {
    final keys = data.keys.toList()..sort();
    final rows = <Widget>[];

    for (final key in keys) {
      if (_shouldHideField(
        fieldKey: key,
        oldValue: null,
        newValue: data[key],
      )) {
        continue;
      }

      final newValue = _formatValue(fieldKey: key, value: data[key]);

      if (newValue == '—') {
        continue;
      }

      rows.add(
        _AuditChangeRow(
          label: _formatFieldLabel(key),
          oldValue: '—',
          newValue: newValue,
        ),
      );
    }

    return rows;
  }

  List<Widget> _buildRemovedRows(Map<String, dynamic> data) {
    final keys = data.keys.toList()..sort();
    final rows = <Widget>[];

    for (final key in keys) {
      if (_shouldHideField(
        fieldKey: key,
        oldValue: data[key],
        newValue: null,
      )) {
        continue;
      }

      final oldValue = _formatValue(fieldKey: key, value: data[key]);

      if (oldValue == '—') {
        continue;
      }

      rows.add(
        _AuditChangeRow(
          label: _formatFieldLabel(key),
          oldValue: oldValue,
          newValue: '—',
        ),
      );
    }

    return rows;
  }

  List<Widget> _buildUpdatedRows(
    Map<String, dynamic> oldValues,
    Map<String, dynamic> newValues,
  ) {
    final keys = <String>{...oldValues.keys, ...newValues.keys}.toList()
      ..sort();

    final rows = <Widget>[];

    for (final key in keys) {
      final oldValue = oldValues[key];
      final newValue = newValues[key];

      if (_shouldHideField(
        fieldKey: key,
        oldValue: oldValue,
        newValue: newValue,
      )) {
        continue;
      }

      if (_areSameRawValues(oldValue, newValue)) {
        continue;
      }

      rows.add(
        _AuditChangeRow(
          label: _formatFieldLabel(key),
          oldValue: _formatValue(fieldKey: key, value: oldValue),
          newValue: _formatValue(fieldKey: key, value: newValue),
        ),
      );
    }

    return rows;
  }

  bool _areSameRawValues(dynamic oldValue, dynamic newValue) {
    return oldValue?.toString() == newValue?.toString();
  }

  bool _shouldHideField({
    required String fieldKey,
    required dynamic oldValue,
    required dynamic newValue,
  }) {
    final cleanFieldKey = fieldKey.trim().toLowerCase();

    if (_isAlwaysHiddenTechnicalField(cleanFieldKey)) {
      return true;
    }

    if (!_looksLikeIdField(cleanFieldKey)) {
      return false;
    }

    if (!lookupResolver.isResolvableField(cleanFieldKey)) {
      return true;
    }

    final oldResolvedValue = lookupResolver.resolveFieldValue(
      fieldKey: cleanFieldKey,
      value: oldValue,
    );
    final newResolvedValue = lookupResolver.resolveFieldValue(
      fieldKey: cleanFieldKey,
      value: newValue,
    );

    return (oldValue == null || oldResolvedValue == null) &&
        (newValue == null || newResolvedValue == null);
  }

  bool _isAlwaysHiddenTechnicalField(String fieldKey) {
    return fieldKey == 'id' ||
        fieldKey == 'company_id' ||
        fieldKey == 'created_by_profile_id' ||
        fieldKey == 'updated_by_profile_id' ||
        fieldKey == 'actor_profile_id';
  }

  bool _looksLikeIdField(String fieldKey) {
    return fieldKey == 'id' || fieldKey.endsWith('_id');
  }

  String _formatValue({required String fieldKey, required dynamic value}) {
    if (value == null) {
      return '—';
    }

    final resolvedValue = lookupResolver.resolveFieldValue(
      fieldKey: fieldKey,
      value: value,
    );

    if (resolvedValue != null && resolvedValue.trim().isNotEmpty) {
      return resolvedValue.trim();
    }

    final resolvedLabel = lookupResolver.resolveFieldLabel(fieldKey);

    if (resolvedLabel != null) {
      return '—';
    }

    if (value is String) {
      final cleanValue = value.trim();
      return cleanValue.isEmpty ? '—' : cleanValue;
    }

    if (value is num || value is bool) {
      return value.toString();
    }

    if (value is List) {
      if (value.isEmpty) {
        return 'Empty list';
      }

      return '${value.length} item${value.length == 1 ? '' : 's'}';
    }

    if (value is Map) {
      if (value.isEmpty) {
        return 'Empty object';
      }

      return 'Updated details';
    }

    return value.toString();
  }

  String _formatFieldLabel(String value) {
    final resolvedLabel = lookupResolver.resolveFieldLabel(value);

    if (resolvedLabel != null) {
      return resolvedLabel;
    }

    final cleanValue = value.trim().replaceAll('_', ' ');

    if (cleanValue.isEmpty) {
      return 'Unknown Field';
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

class _AuditChangeRow extends StatelessWidget {
  const _AuditChangeRow({
    required this.label,
    required this.oldValue,
    required this.newValue,
  });

  final String label;
  final String oldValue;
  final String newValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _ValueLine(label: 'Old', value: oldValue),
          const SizedBox(height: 4),
          _ValueLine(label: 'New', value: newValue),
        ],
      ),
    );
  }
}

class _ValueLine extends StatelessWidget {
  const _ValueLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 36,
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
