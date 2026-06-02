import 'dart:convert';

class AuditLogModel {
  const AuditLogModel({
    this.id,
    this.companyId,
    this.actorProfileId,
    this.actorNameSnapshot,
    this.actorEmailSnapshot,
    this.action = '',
    this.entityType = '',
    this.entityId,
    this.entityLabelSnapshot,
    this.oldData,
    this.newData,
    this.metadata,
    this.createdAt,
  });

  final String? id;
  final String? companyId;
  final String? actorProfileId;
  final String? actorNameSnapshot;
  final String? actorEmailSnapshot;
  final String action;
  final String entityType;
  final String? entityId;
  final String? entityLabelSnapshot;
  final Map<String, dynamic>? oldData;
  final Map<String, dynamic>? newData;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;

  bool get hasOldData => oldData != null && oldData!.isNotEmpty;
  bool get hasNewData => newData != null && newData!.isNotEmpty;
  bool get hasMetadata => metadata != null && metadata!.isNotEmpty;

  String get actionLabel {
    switch (action.trim().toLowerCase()) {
      case 'create_worker':
        return 'Created Worker';
      case 'update_worker':
        return 'Updated Worker';
      case 'deactivate_worker':
        return 'Deactivated Worker';
      case 'reactivate_worker':
        return 'Reactivated Worker';

      case 'create_tool':
        return 'Created Tool';
      case 'update_tool':
        return 'Updated Tool';
      case 'deactivate_tool':
        return 'Deactivated Tool';
      case 'reactivate_tool':
        return 'Reactivated Tool';

      case 'transaction_created':
        return 'Created Transaction';
      case 'transaction_approval_document_uploaded':
        return 'Uploaded Approval Document';
      case 'transaction_approved':
        return 'Approved Transaction';
      case 'transaction_rejected':
        return 'Rejected Transaction';
      case 'transaction_settled':
        return 'Settled Transaction';

      case 'department_created':
        return 'Created Department';
      case 'department_deactivated':
        return 'Deactivated Department';
      case 'department_reactivated':
        return 'Reactivated Department';

      case 'job_title_created':
        return 'Created Job Title';
      case 'job_title_deactivated':
        return 'Deactivated Job Title';
      case 'job_title_reactivated':
        return 'Reactivated Job Title';

      case 'tool_unit_created':
        return 'Created Tool Unit';
      case 'tool_unit_deactivated':
        return 'Deactivated Tool Unit';
      case 'tool_unit_reactivated':
        return 'Reactivated Tool Unit';

      case 'tool_category_created':
        return 'Created Tool Category';
      case 'tool_category_deactivated':
        return 'Deactivated Tool Category';
      case 'tool_category_reactivated':
        return 'Reactivated Tool Category';

      default:
        return _toTitleCase(action);
    }
  }

  String get entityTypeLabel {
    switch (entityType.trim().toLowerCase()) {
      case 'worker':
        return 'Worker';
      case 'tool':
        return 'Tool';
      case 'transaction':
        return 'Transaction';
      case 'company':
        return 'Company';
      case 'company_user':
        return 'Company User';
      case 'company_settings':
        return 'Company Settings';

      case 'department':
        return 'Department';
      case 'job_title':
        return 'Job Title';
      case 'tool_unit':
        return 'Tool Unit';
      case 'tool_category':
        return 'Tool Category';

      default:
        return _toTitleCase(entityType);
    }
  }

  String get actorDisplayName {
    final cleanName = actorNameSnapshot?.trim();

    if (cleanName != null && cleanName.isNotEmpty) {
      return cleanName;
    }

    final cleanEmail = actorEmailSnapshot?.trim();

    if (cleanEmail != null && cleanEmail.isNotEmpty) {
      return cleanEmail;
    }

    return 'Unknown User';
  }

  String get entityDisplayLabel {
    final cleanLabel = entityLabelSnapshot?.trim();

    if (cleanLabel != null && cleanLabel.isNotEmpty) {
      return cleanLabel;
    }

    final cleanEntityId = entityId?.trim();

    if (cleanEntityId != null && cleanEntityId.isNotEmpty) {
      return cleanEntityId;
    }

    return 'Unknown Record';
  }

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] as String?,
      companyId: json['company_id'] as String?,
      actorProfileId: json['actor_profile_id'] as String?,
      actorNameSnapshot: json['actor_name_snapshot'] as String?,
      actorEmailSnapshot: json['actor_email_snapshot'] as String?,
      action: json['action'] as String? ?? '',
      entityType: json['entity_type'] as String? ?? '',
      entityId: json['entity_id'] as String?,
      entityLabelSnapshot: json['entity_label_snapshot'] as String?,
      oldData: _parseJsonObject(json['old_data']),
      newData: _parseJsonObject(json['new_data']),
      metadata: _parseJsonObject(json['metadata']),
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  AuditLogModel copyWith({
    String? id,
    String? companyId,
    String? actorProfileId,
    String? actorNameSnapshot,
    String? actorEmailSnapshot,
    String? action,
    String? entityType,
    String? entityId,
    String? entityLabelSnapshot,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return AuditLogModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      actorProfileId: actorProfileId ?? this.actorProfileId,
      actorNameSnapshot: actorNameSnapshot ?? this.actorNameSnapshot,
      actorEmailSnapshot: actorEmailSnapshot ?? this.actorEmailSnapshot,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      entityLabelSnapshot: entityLabelSnapshot ?? this.entityLabelSnapshot,
      oldData: oldData ?? this.oldData,
      newData: newData ?? this.newData,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static Map<String, dynamic>? _parseJsonObject(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    }

    if (value is Map) {
      return value.map((key, item) {
        return MapEntry(key.toString(), item);
      });
    }

    if (value is String && value.trim().isNotEmpty) {
      try {
        final decodedValue = jsonDecode(value);

        if (decodedValue is Map<String, dynamic>) {
          return Map<String, dynamic>.from(decodedValue);
        }

        if (decodedValue is Map) {
          return decodedValue.map((key, item) {
            return MapEntry(key.toString(), item);
          });
        }
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(value.toString());
  }

  static String _toTitleCase(String value) {
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
