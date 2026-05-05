import '../../data/models/company_profile_model.dart';

enum CompanySettingsAction { none, updatingProfile, uploadingLogo }

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
    this.action = CompanySettingsAction.none,
  });

  final CompanyProfileModel profile;
  final CompanySettingsAction action;

  bool get isSaving => action != CompanySettingsAction.none;

  bool get isUpdatingProfile => action == CompanySettingsAction.updatingProfile;

  bool get isUploadingLogo => action == CompanySettingsAction.uploadingLogo;

  CompanySettingsLoaded copyWith({
    CompanyProfileModel? profile,
    CompanySettingsAction? action,
  }) {
    return CompanySettingsLoaded(
      profile: profile ?? this.profile,
      action: action ?? this.action,
    );
  }
}

class CompanySettingsFailure extends CompanySettingsState {
  const CompanySettingsFailure(this.message);

  final String message;
}
