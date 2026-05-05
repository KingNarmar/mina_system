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
      storekeeperSignatureLabel:
          json['storekeeper_signature_label'] as String?,
      isActive: json['is_active'] as bool,
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
      workerSignatureLabel:
          workerSignatureLabel ?? this.workerSignatureLabel,
      managerSignatureLabel:
          managerSignatureLabel ?? this.managerSignatureLabel,
      storekeeperSignatureLabel:
          storekeeperSignatureLabel ?? this.storekeeperSignatureLabel,
      isActive: isActive ?? this.isActive,
    );
  }
}