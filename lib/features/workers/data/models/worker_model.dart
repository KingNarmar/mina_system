class WorkerModel {
  const WorkerModel({
    this.id,
    this.companyId,
    this.workerCode,
    required this.name,
    required this.hrCode,
    required this.department,
    required this.jobTitle,
    this.departmentId,
    this.jobTitleId,
    this.phone,
    this.email,
    this.status = 'active',
    this.notes,
    this.createdByProfileId,
    this.updatedByProfileId,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? companyId;
  final String? workerCode;

  /// UI-friendly worker name.
  /// Maps to Supabase column: full_name.
  final String name;

  final String hrCode;

  /// UI-friendly department name.
  /// Real Supabase relation is department_id.
  final String department;

  /// UI-friendly job title name.
  /// Real Supabase relation is job_title_id.
  final String jobTitle;

  final String? departmentId;
  final String? jobTitleId;
  final String? phone;
  final String? email;
  final String status;
  final String? notes;
  final String? createdByProfileId;
  final String? updatedByProfileId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    return WorkerModel(
      id: json['id'] as String?,
      companyId: json['company_id'] as String?,
      workerCode: json['worker_code'] as String?,
      name: json['full_name'] as String? ?? '',
      hrCode: json['hr_code'] as String? ?? '',
      departmentId: json['department_id'] as String?,
      jobTitleId: json['job_title_id'] as String?,
      department: _readRelatedName(
        json: json,
        directKey: 'department_name',
        relationKey: 'departments',
      ),
      jobTitle: _readRelatedName(
        json: json,
        directKey: 'job_title_name',
        relationKey: 'job_titles',
      ),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      status: json['status'] as String? ?? 'active',
      notes: json['notes'] as String?,
      createdByProfileId: json['created_by_profile_id'] as String?,
      updatedByProfileId: json['updated_by_profile_id'] as String?,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'company_id': companyId,
      'worker_code': workerCode?.trim(),
      'hr_code': hrCode.trim(),
      'full_name': name.trim(),
      'department_id': departmentId,
      'job_title_id': jobTitleId,
      'phone': _emptyToNull(phone),
      'email': _emptyToNull(email),
      'status': status,
      'notes': _emptyToNull(notes),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'worker_code': workerCode?.trim(),
      'hr_code': hrCode.trim(),
      'full_name': name.trim(),
      'department_id': departmentId,
      'job_title_id': jobTitleId,
      'phone': _emptyToNull(phone),
      'email': _emptyToNull(email),
      'status': status,
      'notes': _emptyToNull(notes),
    };
  }

  WorkerModel copyWith({
    String? id,
    String? companyId,
    String? workerCode,
    String? name,
    String? hrCode,
    String? department,
    String? jobTitle,
    String? departmentId,
    String? jobTitleId,
    String? phone,
    String? email,
    String? status,
    String? notes,
    String? createdByProfileId,
    String? updatedByProfileId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkerModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      workerCode: workerCode ?? this.workerCode,
      name: name ?? this.name,
      hrCode: hrCode ?? this.hrCode,
      department: department ?? this.department,
      jobTitle: jobTitle ?? this.jobTitle,
      departmentId: departmentId ?? this.departmentId,
      jobTitleId: jobTitleId ?? this.jobTitleId,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdByProfileId: createdByProfileId ?? this.createdByProfileId,
      updatedByProfileId: updatedByProfileId ?? this.updatedByProfileId,
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

    return '';
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
