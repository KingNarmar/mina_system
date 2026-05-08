import '../../data/models/company_document_template_model.dart';
import '../../data/models/company_profile_model.dart';
import '../../data/models/company_report_settings_model.dart';

enum CompanySettingsAction {
  none,
  updatingProfile,
  uploadingLogo,
  updatingReportSettings,
  updatingDocumentTemplate,
}

abstract class CompanySettingsState {
  const CompanySettingsState();
}

class CompanySettingsInitial extends CompanySettingsState {
  const CompanySettingsInitial();
}

class CompanySettingsLoading extends CompanySettingsState {
  const CompanySettingsLoading();
}

class CompanySettingsLoaded extends CompanySettingsState {
  const CompanySettingsLoaded({
    required this.profile,
    required this.reportSettings,
    required this.documentTemplates,
    this.action = CompanySettingsAction.none,
    this.errorMessage,
  });

  final CompanyProfileModel profile;
  final CompanyReportSettingsModel reportSettings;
  final List<CompanyDocumentTemplateModel> documentTemplates;
  final CompanySettingsAction action;
  final String? errorMessage;

  bool get isSaving => action != CompanySettingsAction.none;

  bool get isUpdatingProfile => action == CompanySettingsAction.updatingProfile;

  bool get isUploadingLogo => action == CompanySettingsAction.uploadingLogo;

  bool get isUpdatingReportSettings =>
      action == CompanySettingsAction.updatingReportSettings;

  bool get isUpdatingDocumentTemplate =>
      action == CompanySettingsAction.updatingDocumentTemplate;

  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;

  CompanySettingsLoaded copyWith({
    CompanyProfileModel? profile,
    CompanyReportSettingsModel? reportSettings,
    List<CompanyDocumentTemplateModel>? documentTemplates,
    CompanySettingsAction? action,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return CompanySettingsLoaded(
      profile: profile ?? this.profile,
      reportSettings: reportSettings ?? this.reportSettings,
      documentTemplates: documentTemplates ?? this.documentTemplates,
      action: action ?? this.action,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

class CompanySettingsFailure extends CompanySettingsState {
  const CompanySettingsFailure(this.message);

  final String message;
}
