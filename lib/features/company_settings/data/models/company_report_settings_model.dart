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
    );
  }
}
