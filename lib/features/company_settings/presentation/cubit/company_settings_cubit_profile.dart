part of 'company_settings_cubit.dart';

extension CompanySettingsCubitProfile on CompanySettingsCubit {
  Future<void> updateCompanyProfile({
    required CompanyProfileModel profile,
  }) async {
    final currentState = state;

    if (currentState is! CompanySettingsLoaded) {
      return;
    }

    final actionState = currentState.copyWith(
      action: CompanySettingsAction.updatingProfile,
      clearErrorMessage: true,
    );

    emitState(actionState);

    final canContinue = await _ensureOnline(actionState);
    if (!canContinue) {
      return;
    }

    try {
      final updatedProfile = await _repo.updateCompanyProfile(profile: profile);

      emitState(
        actionState.copyWith(
          profile: updatedProfile,
          action: CompanySettingsAction.none,
          clearErrorMessage: true,
        ),
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('UpdateCompanyProfile error: $error');
        debugPrint('UpdateCompanyProfile stackTrace: $stackTrace');
      }

      emitState(
        actionState.copyWith(
          action: CompanySettingsAction.none,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to update company profile.',
          ),
        ),
      );
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

    final actionState = currentState.copyWith(
      action: CompanySettingsAction.uploadingLogo,
      clearErrorMessage: true,
    );

    emitState(actionState);

    final canContinue = await _ensureOnline(actionState);
    if (!canContinue) {
      return;
    }

    try {
      final updatedProfile = await _repo.uploadCompanyLogo(
        companyId: companyId,
        bytes: bytes,
        fileExtension: fileExtension,
        contentType: contentType,
      );

      emitState(
        actionState.copyWith(
          profile: updatedProfile,
          action: CompanySettingsAction.none,
          clearErrorMessage: true,
        ),
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('UploadCompanyLogo error: $error');
        debugPrint('UploadCompanyLogo stackTrace: $stackTrace');
      }

      emitState(
        actionState.copyWith(
          action: CompanySettingsAction.none,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to upload company logo.',
          ),
        ),
      );
    }
  }
}
