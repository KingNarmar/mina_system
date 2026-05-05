import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/company_profile_model.dart';
import '../../data/models/company_report_settings_model.dart';
import '../../data/repo/company_settings_repo.dart';
import 'company_settings_state.dart';

class CompanySettingsCubit extends Cubit<CompanySettingsState> {
  CompanySettingsCubit({CompanySettingsRepo? repo})
    : _repo = repo ?? CompanySettingsRepo(),
      super(const CompanySettingsInitial());

  final CompanySettingsRepo _repo;

  Future<void> loadCompanyProfile({required String companyId}) async {
    emit(const CompanySettingsLoading());

    try {
      final profile = await _repo.getCompanyProfile(companyId: companyId);
      final reportSettings = await _repo.getCompanyReportSettings(
        companyId: companyId,
      );

      emit(
        CompanySettingsLoaded(profile: profile, reportSettings: reportSettings),
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('LoadCompanyProfile error: $error');
        debugPrint('LoadCompanyProfile stackTrace: $stackTrace');
      }

      emit(const CompanySettingsFailure('Unable to load company profile.'));
    }
  }

  Future<void> updateCompanyProfile({
    required CompanyProfileModel profile,
  }) async {
    final currentState = state;

    if (currentState is! CompanySettingsLoaded) {
      return;
    }

    emit(currentState.copyWith(action: CompanySettingsAction.updatingProfile));

    try {
      final updatedProfile = await _repo.updateCompanyProfile(profile: profile);

      emit(
        CompanySettingsLoaded(
          profile: updatedProfile,
          reportSettings: currentState.reportSettings,
          action: CompanySettingsAction.none,
        ),
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('UpdateCompanyProfile error: $error');
        debugPrint('UpdateCompanyProfile stackTrace: $stackTrace');
      }

      emit(const CompanySettingsFailure('Unable to update company profile.'));
    }
  }

  Future<void> updateCompanyReportSettings({
    required CompanyReportSettingsModel reportSettings,
  }) async {
    final currentState = state;

    if (currentState is! CompanySettingsLoaded) {
      return;
    }

    emit(
      currentState.copyWith(
        action: CompanySettingsAction.updatingReportSettings,
      ),
    );

    try {
      final updatedReportSettings = await _repo.updateCompanyReportSettings(
        reportSettings: reportSettings,
      );

      emit(
        CompanySettingsLoaded(
          profile: currentState.profile,
          reportSettings: updatedReportSettings,
          action: CompanySettingsAction.none,
        ),
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('UpdateCompanyReportSettings error: $error');
        debugPrint('UpdateCompanyReportSettings stackTrace: $stackTrace');
      }

      emit(const CompanySettingsFailure('Unable to update report settings.'));
    }
  }

  Future<void> uploadCompanyLogo({
    required String companyId,
    required Uint8List bytes,
    required String fileExtension,
    required String contentType,
  }) async {
    final currentState = state;

    if (currentState is! CompanySettingsLoaded) {
      return;
    }

    emit(currentState.copyWith(action: CompanySettingsAction.uploadingLogo));

    try {
      final updatedProfile = await _repo.uploadCompanyLogo(
        companyId: companyId,
        bytes: bytes,
        fileExtension: fileExtension,
        contentType: contentType,
      );

      emit(
        CompanySettingsLoaded(
          profile: updatedProfile,
          reportSettings: currentState.reportSettings,
          action: CompanySettingsAction.none,
        ),
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('UploadCompanyLogo error: $error');
        debugPrint('UploadCompanyLogo stackTrace: $stackTrace');
      }

      emit(const CompanySettingsFailure('Unable to upload company logo.'));
    }
  }
}
