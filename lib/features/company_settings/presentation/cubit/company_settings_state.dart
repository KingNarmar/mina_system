import '../../data/models/company_profile_model.dart';
import '../../data/models/company_report_settings_model.dart';

enum CompanySettingsAction {
  none,
  updatingProfile,
  uploadingLogo,
  updatingReportSettings,
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
    this.action = CompanySettingsAction.none,
  });

  final CompanyProfileModel profile;
  final CompanyReportSettingsModel reportSettings;
  final CompanySettingsAction action;

  bool get isSaving => action != CompanySettingsAction.none;

  bool get isUpdatingProfile => action == CompanySettingsAction.updatingProfile;

  bool get isUploadingLogo => action == CompanySettingsAction.uploadingLogo;

  bool get isUpdatingReportSettings =>
      action == CompanySettingsAction.updatingReportSettings;

  CompanySettingsLoaded copyWith({
    CompanyProfileModel? profile,
    CompanyReportSettingsModel? reportSettings,
    CompanySettingsAction? action,
  }) {
    return CompanySettingsLoaded(
      profile: profile ?? this.profile,
      reportSettings: reportSettings ?? this.reportSettings,
      action: action ?? this.action,
    );
  }
}

class CompanySettingsFailure extends CompanySettingsState {
  const CompanySettingsFailure(this.message);

  final String message;
}