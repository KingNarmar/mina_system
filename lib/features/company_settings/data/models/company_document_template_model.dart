class CompanyDocumentTemplateModel {
  const CompanyDocumentTemplateModel({
    required this.id,
    required this.companyId,
    required this.reportType,
    required this.documentTitle,
    required this.documentCode,
    required this.issueNo,
    required this.revisionNo,
    required this.effectiveDate,
    this.preparedByTitle,
    this.checkedByTitle,
    this.approvedByTitle,
    this.workerSignatureLabel,
    this.managerSignatureLabel,
    this.storekeeperSignatureLabel,
    required this.isActive,
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
  final String reportType;
  final String documentTitle;
  final String documentCode;
  final String issueNo;
  final String revisionNo;
  final DateTime effectiveDate;
  final String? preparedByTitle;
  final String? checkedByTitle;
  final String? approvedByTitle;
  final String? workerSignatureLabel;
  final String? managerSignatureLabel;
  final String? storekeeperSignatureLabel;
  final bool isActive;
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

  factory CompanyDocumentTemplateModel.fromJson(Map<String, dynamic> json) {
    return CompanyDocumentTemplateModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      reportType: json['report_type'].toString(),
      documentTitle: json['document_title'] as String,
      documentCode: json['document_code'] as String,
      issueNo: json['issue_no'] as String,
      revisionNo: json['revision_no'] as String,
      effectiveDate: DateTime.parse(json['effective_date'] as String),
      preparedByTitle: json['prepared_by_title'] as String?,
      checkedByTitle: json['checked_by_title'] as String?,
      approvedByTitle: json['approved_by_title'] as String?,
      workerSignatureLabel: json['worker_signature_label'] as String?,
      managerSignatureLabel: json['manager_signature_label'] as String?,
      storekeeperSignatureLabel: json['storekeeper_signature_label'] as String?,
      isActive: json['is_active'] as bool,
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
      'document_title': documentTitle.trim(),
      'document_code': documentCode.trim(),
      'issue_no': issueNo.trim(),
      'revision_no': revisionNo.trim(),
      'effective_date': effectiveDate.toIso8601String().split('T').first,
      'prepared_by_title': preparedByTitle?.trim(),
      'checked_by_title': checkedByTitle?.trim(),
      'approved_by_title': approvedByTitle?.trim(),
      'worker_signature_label': workerSignatureLabel?.trim(),
      'manager_signature_label': managerSignatureLabel?.trim(),
      'storekeeper_signature_label': storekeeperSignatureLabel?.trim(),
      'is_active': isActive,
    };
  }

  CompanyDocumentTemplateModel copyWith({
    String? id,
    String? companyId,
    String? reportType,
    String? documentTitle,
    String? documentCode,
    String? issueNo,
    String? revisionNo,
    DateTime? effectiveDate,
    String? preparedByTitle,
    String? checkedByTitle,
    String? approvedByTitle,
    String? workerSignatureLabel,
    String? managerSignatureLabel,
    String? storekeeperSignatureLabel,
    bool? isActive,
    String? createdByProfileId,
    String? updatedByProfileId,
    String? createdByProfileName,
    String? createdByProfileEmail,
    String? updatedByProfileName,
    String? updatedByProfileEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompanyDocumentTemplateModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      reportType: reportType ?? this.reportType,
      documentTitle: documentTitle ?? this.documentTitle,
      documentCode: documentCode ?? this.documentCode,
      issueNo: issueNo ?? this.issueNo,
      revisionNo: revisionNo ?? this.revisionNo,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      preparedByTitle: preparedByTitle ?? this.preparedByTitle,
      checkedByTitle: checkedByTitle ?? this.checkedByTitle,
      approvedByTitle: approvedByTitle ?? this.approvedByTitle,
      workerSignatureLabel: workerSignatureLabel ?? this.workerSignatureLabel,
      managerSignatureLabel:
          managerSignatureLabel ?? this.managerSignatureLabel,
      storekeeperSignatureLabel:
          storekeeperSignatureLabel ?? this.storekeeperSignatureLabel,
      isActive: isActive ?? this.isActive,
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
