enum TransactionType { issue, returnTool, lost, damaged }

class TransactionModel {
  const TransactionModel({
    this.id,
    this.companyId,
    required this.transactionCode,
    required this.type,
    this.workerId,
    required this.workerHrCode,
    required this.workerName,
    this.workerDepartment = '',
    this.workerJobTitle = '',
    this.toolId,
    required this.toolCode,
    required this.toolName,
    required this.unit,
    this.toolCategory = '',
    required this.quantity,
    required this.dateTime,
    this.imagePath,
    this.note,
    this.approvalRequired = false,
    this.approvalStatus = 'not_required',
    this.approvalDocumentPath,
    this.approvalDecisionNote,
    this.approvalDecidedByProfileId,
    this.approvalDecidedAt,
    this.settlementStatus = 'not_required',
    this.settlementNote,
    this.settledByProfileId,
    this.settledAt,
    this.createdByProfileId,
    this.updatedAt,
  });

  final String? id;
  final String? companyId;
  final String transactionCode;
  final TransactionType type;

  final String? workerId;
  final String workerHrCode;
  final String workerName;
  final String workerDepartment;
  final String workerJobTitle;

  final String? toolId;
  final String toolCode;
  final String toolName;
  final String unit;
  final String toolCategory;

  final double quantity;
  final DateTime dateTime;
  final String? imagePath;
  final String? note;

  final bool approvalRequired;
  final String approvalStatus;
  final String? approvalDocumentPath;
  final String? approvalDecisionNote;
  final String? approvalDecidedByProfileId;
  final DateTime? approvalDecidedAt;

  final String settlementStatus;
  final String? settlementNote;
  final String? settledByProfileId;
  final DateTime? settledAt;

  final String? createdByProfileId;
  final DateTime? updatedAt;

  bool get isIssue => type == TransactionType.issue;
  bool get isReturn => type == TransactionType.returnTool;
  bool get isLost => type == TransactionType.lost;
  bool get isDamaged => type == TransactionType.damaged;
  bool get isLostOrDamaged => isLost || isDamaged;

  bool get isClosingTransaction => !isIssue;

  bool get isApprovalPending => _isSameStatus(approvalStatus, 'pending');
  bool get isApprovalApproved => _isSameStatus(approvalStatus, 'approved');
  bool get isApprovalRejected => _isSameStatus(approvalStatus, 'rejected');

  bool get isSettlementNotRequired {
    return _isSameStatus(settlementStatus, 'not_required');
  }

  bool get isPendingSettlement {
    return _isSameStatus(settlementStatus, 'pending_settlement');
  }

  bool get isSettled => _isSameStatus(settlementStatus, 'settled');

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String?,
      companyId: json['company_id'] as String?,
      transactionCode: json['transaction_code'] as String? ?? '',
      type: _transactionTypeFromJson(json['transaction_type'] as String?),
      workerId: json['worker_id'] as String?,
      workerHrCode: json['worker_hr_code_snapshot'] as String? ?? '',
      workerName: json['worker_name_snapshot'] as String? ?? '',
      workerDepartment: json['worker_department_snapshot'] as String? ?? '',
      workerJobTitle: json['worker_job_title_snapshot'] as String? ?? '',
      toolId: json['tool_id'] as String?,
      toolCode: json['tool_code_snapshot'] as String? ?? '',
      toolName: json['tool_name_snapshot'] as String? ?? '',
      unit: json['tool_unit_snapshot'] as String? ?? '',
      toolCategory: json['tool_category_snapshot'] as String? ?? '',
      quantity: _parseDouble(json['quantity']),
      dateTime: _parseDateTime(json['created_at']) ?? DateTime.now(),
      imagePath: json['proof_image_path'] as String?,
      note: json['note'] as String?,
      approvalRequired: json['approval_required'] as bool? ?? false,
      approvalStatus: json['approval_status'] as String? ?? 'not_required',
      approvalDocumentPath: json['approval_document_path'] as String?,
      approvalDecisionNote: json['approval_decision_note'] as String?,
      approvalDecidedByProfileId:
          json['approval_decided_by_profile_id'] as String?,
      approvalDecidedAt: _parseDateTime(json['approval_decided_at']),
      settlementStatus: json['settlement_status'] as String? ?? 'not_required',
      settlementNote: json['settlement_note'] as String?,
      settledByProfileId: json['settled_by_profile_id'] as String?,
      settledAt: _parseDateTime(json['settled_at']),
      createdByProfileId: json['created_by_profile_id'] as String?,
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'company_id': companyId,
      'transaction_code': transactionCode.trim(),
      'transaction_type': _transactionTypeToJson(type),
      'worker_id': workerId,
      'worker_hr_code_snapshot': workerHrCode.trim(),
      'worker_name_snapshot': workerName.trim(),
      'worker_department_snapshot': workerDepartment.trim(),
      'worker_job_title_snapshot': workerJobTitle.trim(),
      'tool_id': toolId,
      'tool_code_snapshot': toolCode.trim(),
      'tool_name_snapshot': toolName.trim(),
      'tool_unit_snapshot': unit.trim(),
      'tool_category_snapshot': toolCategory.trim(),
      'quantity': quantity,
      'proof_image_path': _emptyToNull(imagePath),
      'note': _emptyToNull(note),
      'approval_required': approvalRequired,
      'approval_status': approvalStatus,
      'approval_document_path': _emptyToNull(approvalDocumentPath),
      'approval_decision_note': _emptyToNull(approvalDecisionNote),
      'approval_decided_by_profile_id': approvalDecidedByProfileId,
      'approval_decided_at': approvalDecidedAt?.toIso8601String(),
      'settlement_status': settlementStatus,
      'settlement_note': _emptyToNull(settlementNote),
      'settled_by_profile_id': settledByProfileId,
      'settled_at': settledAt?.toIso8601String(),
      'created_by_profile_id': createdByProfileId,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'transaction_type': _transactionTypeToJson(type),
      'worker_id': workerId,
      'worker_hr_code_snapshot': workerHrCode.trim(),
      'worker_name_snapshot': workerName.trim(),
      'worker_department_snapshot': workerDepartment.trim(),
      'worker_job_title_snapshot': workerJobTitle.trim(),
      'tool_id': toolId,
      'tool_code_snapshot': toolCode.trim(),
      'tool_name_snapshot': toolName.trim(),
      'tool_unit_snapshot': unit.trim(),
      'tool_category_snapshot': toolCategory.trim(),
      'quantity': quantity,
      'proof_image_path': _emptyToNull(imagePath),
      'note': _emptyToNull(note),
      'approval_required': approvalRequired,
      'approval_status': approvalStatus,
      'approval_document_path': _emptyToNull(approvalDocumentPath),
      'approval_decision_note': _emptyToNull(approvalDecisionNote),
      'approval_decided_by_profile_id': approvalDecidedByProfileId,
      'approval_decided_at': approvalDecidedAt?.toIso8601String(),
      'settlement_status': settlementStatus,
      'settlement_note': _emptyToNull(settlementNote),
      'settled_by_profile_id': settledByProfileId,
      'settled_at': settledAt?.toIso8601String(),
    };
  }

  TransactionModel copyWith({
    String? id,
    String? companyId,
    String? transactionCode,
    TransactionType? type,
    String? workerId,
    String? workerHrCode,
    String? workerName,
    String? workerDepartment,
    String? workerJobTitle,
    String? toolId,
    String? toolCode,
    String? toolName,
    String? unit,
    String? toolCategory,
    double? quantity,
    DateTime? dateTime,
    String? imagePath,
    String? note,
    bool? approvalRequired,
    String? approvalStatus,
    String? approvalDocumentPath,
    String? approvalDecisionNote,
    String? approvalDecidedByProfileId,
    DateTime? approvalDecidedAt,
    String? settlementStatus,
    String? settlementNote,
    String? settledByProfileId,
    DateTime? settledAt,
    String? createdByProfileId,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      transactionCode: transactionCode ?? this.transactionCode,
      type: type ?? this.type,
      workerId: workerId ?? this.workerId,
      workerHrCode: workerHrCode ?? this.workerHrCode,
      workerName: workerName ?? this.workerName,
      workerDepartment: workerDepartment ?? this.workerDepartment,
      workerJobTitle: workerJobTitle ?? this.workerJobTitle,
      toolId: toolId ?? this.toolId,
      toolCode: toolCode ?? this.toolCode,
      toolName: toolName ?? this.toolName,
      unit: unit ?? this.unit,
      toolCategory: toolCategory ?? this.toolCategory,
      quantity: quantity ?? this.quantity,
      dateTime: dateTime ?? this.dateTime,
      imagePath: imagePath ?? this.imagePath,
      note: note ?? this.note,
      approvalRequired: approvalRequired ?? this.approvalRequired,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      approvalDocumentPath: approvalDocumentPath ?? this.approvalDocumentPath,
      approvalDecisionNote: approvalDecisionNote ?? this.approvalDecisionNote,
      approvalDecidedByProfileId:
          approvalDecidedByProfileId ?? this.approvalDecidedByProfileId,
      approvalDecidedAt: approvalDecidedAt ?? this.approvalDecidedAt,
      settlementStatus: settlementStatus ?? this.settlementStatus,
      settlementNote: settlementNote ?? this.settlementNote,
      settledByProfileId: settledByProfileId ?? this.settledByProfileId,
      settledAt: settledAt ?? this.settledAt,
      createdByProfileId: createdByProfileId ?? this.createdByProfileId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static TransactionType _transactionTypeFromJson(String? value) {
    switch (value) {
      case 'issue':
        return TransactionType.issue;
      case 'return':
        return TransactionType.returnTool;
      case 'lost':
        return TransactionType.lost;
      case 'damaged':
        return TransactionType.damaged;
      default:
        return TransactionType.issue;
    }
  }

  static String _transactionTypeToJson(TransactionType type) {
    switch (type) {
      case TransactionType.issue:
        return 'issue';
      case TransactionType.returnTool:
        return 'return';
      case TransactionType.lost:
        return 'lost';
      case TransactionType.damaged:
        return 'damaged';
    }
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.parse(value as String);
  }

  static double _parseDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  static String? _emptyToNull(String? value) {
    final trimmedValue = value?.trim();

    if (trimmedValue == null || trimmedValue.isEmpty) {
      return null;
    }

    return trimmedValue;
  }

  static bool _isSameStatus(String firstValue, String secondValue) {
    return firstValue.trim().toLowerCase() == secondValue.trim().toLowerCase();
  }
}
