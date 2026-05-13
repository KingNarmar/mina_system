class ToolModel {
  const ToolModel({
    this.id,
    this.companyId,
    this.toolCode = '',
    required this.toolName,
    required this.unit,
    required this.category,
    this.unitId,
    this.categoryId,
    this.description,
    this.status = 'active',
    this.createdByProfileId,
    this.updatedByProfileId,
    this.createdByProfileName,
    this.createdByProfileEmail,
    this.updatedByProfileName,
    this.updatedByProfileEmail,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? companyId;
  final String toolCode;

  /// UI-friendly tool name.
  /// Maps to Supabase column: tool_name.
  final String toolName;

  /// UI-friendly unit name.
  /// Real Supabase relation is unit_id.
  final String unit;

  /// UI-friendly category name.
  /// Real Supabase relation is category_id.
  final String category;

  final String? unitId;
  final String? categoryId;
  final String? description;
  final String status;
  final String? createdByProfileId;
  final String? updatedByProfileId;
  final String? createdByProfileName;
  final String? createdByProfileEmail;
  final String? updatedByProfileName;
  final String? updatedByProfileEmail;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get createdByDisplayName {
    return _resolveProfileDisplayName(
      name: createdByProfileName,
      email: createdByProfileEmail,
    );
  }

  String get updatedByDisplayName {
    return _resolveProfileDisplayName(
      name: updatedByProfileName,
      email: updatedByProfileEmail,
    );
  }

  factory ToolModel.fromJson(Map<String, dynamic> json) {
    return ToolModel(
      id: json['id'] as String?,
      companyId: json['company_id'] as String?,
      toolCode: json['tool_code'] as String? ?? '',
      toolName: json['tool_name'] as String? ?? '',
      unitId: json['unit_id'] as String?,
      categoryId: json['category_id'] as String?,
      unit: _readRelatedName(
        json: json,
        directKey: 'unit_name',
        relationKey: 'tool_units',
      ),
      category: _readRelatedName(
        json: json,
        directKey: 'category_name',
        relationKey: 'tool_categories',
      ),
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'active',
      createdByProfileId: json['created_by_profile_id'] as String?,
      updatedByProfileId: json['updated_by_profile_id'] as String?,
      createdByProfileName: _readRelatedProfileValue(
        json: json,
        directKey: 'created_by_profile_name',
        relationKey: 'created_by_profile',
        fieldKey: 'full_name',
      ),
      createdByProfileEmail: _readRelatedProfileValue(
        json: json,
        directKey: 'created_by_profile_email',
        relationKey: 'created_by_profile',
        fieldKey: 'email',
      ),
      updatedByProfileName: _readRelatedProfileValue(
        json: json,
        directKey: 'updated_by_profile_name',
        relationKey: 'updated_by_profile',
        fieldKey: 'full_name',
      ),
      updatedByProfileEmail: _readRelatedProfileValue(
        json: json,
        directKey: 'updated_by_profile_email',
        relationKey: 'updated_by_profile',
        fieldKey: 'email',
      ),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'company_id': companyId,
      'tool_code': toolCode.trim(),
      'tool_name': toolName.trim(),
      'unit_id': unitId,
      'category_id': categoryId,
      'description': _emptyToNull(description),
      'status': status,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'tool_code': toolCode.trim(),
      'tool_name': toolName.trim(),
      'unit_id': unitId,
      'category_id': categoryId,
      'description': _emptyToNull(description),
      'status': status,
    };
  }

  ToolModel copyWith({
    String? id,
    String? companyId,
    String? toolCode,
    String? toolName,
    String? unit,
    String? category,
    String? unitId,
    String? categoryId,
    String? description,
    String? status,
    String? createdByProfileId,
    String? updatedByProfileId,
    String? createdByProfileName,
    String? createdByProfileEmail,
    String? updatedByProfileName,
    String? updatedByProfileEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ToolModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      toolCode: toolCode ?? this.toolCode,
      toolName: toolName ?? this.toolName,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      unitId: unitId ?? this.unitId,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      status: status ?? this.status,
      createdByProfileId: createdByProfileId ?? this.createdByProfileId,
      updatedByProfileId: updatedByProfileId ?? this.updatedByProfileId,
      createdByProfileName: createdByProfileName ?? this.createdByProfileName,
      createdByProfileEmail:
          createdByProfileEmail ?? this.createdByProfileEmail,
      updatedByProfileName: updatedByProfileName ?? this.updatedByProfileName,
      updatedByProfileEmail:
          updatedByProfileEmail ?? this.updatedByProfileEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String _readRelatedName({
    required Map<String, dynamic> json,
    required String directKey,
    required String relationKey,
  }) {
    final directValue = json[directKey];

    if (directValue is String) {
      return directValue;
    }

    final relationValue = json[relationKey];

    if (relationValue is Map<String, dynamic>) {
      return relationValue['name'] as String? ?? '';
    }

    if (relationValue is Map) {
      return relationValue['name']?.toString() ?? '';
    }

    return '';
  }

  static String? _readRelatedProfileValue({
    required Map<String, dynamic> json,
    required String directKey,
    required String relationKey,
    required String fieldKey,
  }) {
    final directValue = json[directKey];

    if (directValue is String) {
      return directValue;
    }

    final relationValue = json[relationKey];

    if (relationValue is Map<String, dynamic>) {
      return relationValue[fieldKey] as String?;
    }

    if (relationValue is Map) {
      return relationValue[fieldKey]?.toString();
    }

    return null;
  }

  static String _resolveProfileDisplayName({
    required String? name,
    required String? email,
  }) {
    final cleanName = name?.trim();

    if (cleanName != null && cleanName.isNotEmpty) {
      return cleanName;
    }

    final cleanEmail = email?.trim();

    if (cleanEmail != null && cleanEmail.isNotEmpty) {
      return cleanEmail;
    }

    return 'Unknown User';
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.parse(value as String);
  }

  static String? _emptyToNull(String? value) {
    final trimmedValue = value?.trim();

    if (trimmedValue == null || trimmedValue.isEmpty) {
      return null;
    }

    return trimmedValue;
  }
}
