import '../../data/models/company_profile_model.dart';

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
  const CompanySettingsLoaded({required this.profile, this.isSaving = false});

  final CompanyProfileModel profile;
  final bool isSaving;

  CompanySettingsLoaded copyWith({
    CompanyProfileModel? profile,
    bool? isSaving,
  }) {
    return CompanySettingsLoaded(
      profile: profile ?? this.profile,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class CompanySettingsFailure extends CompanySettingsState {
  const CompanySettingsFailure(this.message);

  final String message;
}
