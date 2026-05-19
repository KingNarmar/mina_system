class CompanyReportSettingsModel {
  const CompanyReportSettingsModel({
    required this.id,
    required this.companyId,
    required this.defaultTimezone,
    required this.dateFormat,
    required this.timeFormat,
    required this.showCompanyLogo,
    required this.showCompanyDetails,
    required this.showDocumentControl,
    required this.showGeneratedBy,
    this.reportFooterText,
    this.custodyResponsibilityStatement,
    this.lossDamageResponsibilityStatement,
    this.createdByProfileId,
    this.updatedByProfileId,
    this.createdByProfileName,
    this.createdByProfileEmail,
    this.updatedByProfileName,
    this.updatedByProfileEmail,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String companyId;
  final String defaultTimezone;
  final String dateFormat;
  final String timeFormat;
  final bool showCompanyLogo;
  final bool showCompanyDetails;
  final bool showDocumentControl;
  final bool showGeneratedBy;
  final String? reportFooterText;
  final String? custodyResponsibilityStatement;
  final String? lossDamageResponsibilityStatement;
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

  factory CompanyReportSettingsModel.fromJson(Map<String, dynamic> json) {
    return CompanyReportSettingsModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      defaultTimezone: json['default_timezone'] as String,
      dateFormat: json['date_format'] as String,
      timeFormat: json['time_format'] as String,
      showCompanyLogo: json['show_company_logo'] as bool,
      showCompanyDetails: json['show_company_details'] as bool,
      showDocumentControl: json['show_document_control'] as bool,
      showGeneratedBy: json['show_generated_by'] as bool,
      reportFooterText: json['report_footer_text'] as String?,
      custodyResponsibilityStatement:
          json['custody_responsibility_statement'] as String?,
      lossDamageResponsibilityStatement:
          json['loss_damage_responsibility_statement'] as String?,
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

  Map<String, dynamic> toUpdateJson() {
    return {
      'default_timezone': defaultTimezone.trim(),
      'date_format': dateFormat.trim(),
      'time_format': timeFormat.trim(),
      'show_company_logo': showCompanyLogo,
      'show_company_details': showCompanyDetails,
      'show_document_control': showDocumentControl,
      'show_generated_by': showGeneratedBy,
      'report_footer_text': reportFooterText?.trim(),
      'custody_responsibility_statement': custodyResponsibilityStatement
          ?.trim(),
      'loss_damage_responsibility_statement': lossDamageResponsibilityStatement
          ?.trim(),
    };
  }

  CompanyReportSettingsModel copyWith({
    String? id,
    String? companyId,
    String? defaultTimezone,
    String? dateFormat,
    String? timeFormat,
    bool? showCompanyLogo,
    bool? showCompanyDetails,
    bool? showDocumentControl,
    bool? showGeneratedBy,
    String? reportFooterText,
    String? custodyResponsibilityStatement,
    String? lossDamageResponsibilityStatement,
    String? createdByProfileId,
    String? updatedByProfileId,
    String? createdByProfileName,
    String? createdByProfileEmail,
    String? updatedByProfileName,
    String? updatedByProfileEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompanyReportSettingsModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      defaultTimezone: defaultTimezone ?? this.defaultTimezone,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      showCompanyLogo: showCompanyLogo ?? this.showCompanyLogo,
      showCompanyDetails: showCompanyDetails ?? this.showCompanyDetails,
      showDocumentControl: showDocumentControl ?? this.showDocumentControl,
      showGeneratedBy: showGeneratedBy ?? this.showGeneratedBy,
      reportFooterText: reportFooterText ?? this.reportFooterText,
      custodyResponsibilityStatement:
          custodyResponsibilityStatement ?? this.custodyResponsibilityStatement,
      lossDamageResponsibilityStatement:
          lossDamageResponsibilityStatement ??
          this.lossDamageResponsibilityStatement,
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

    if (value is DateTime) {
      return value;
    }

    return DateTime.parse(value.toString());
  }
}
