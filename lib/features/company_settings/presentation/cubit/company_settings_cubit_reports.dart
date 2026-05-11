part of 'company_settings_cubit.dart';

extension CompanySettingsCubitReports on CompanySettingsCubit {
  Future<void> updateCompanyReportSettings({
    required CompanyReportSettingsModel reportSettings,
  }) async {
    final currentState = state;

    if (currentState is! CompanySettingsLoaded) {
      return;
    }

    final actionState = currentState.copyWith(
      action: CompanySettingsAction.updatingReportSettings,
      clearErrorMessage: true,
    );

    emitState(actionState);

    final canContinue = await _ensureOnline(actionState);
    if (!canContinue) {
      return;
    }

    try {
      final updatedReportSettings = await _repo.updateCompanyReportSettings(
        reportSettings: reportSettings,
      );

      emitState(
        actionState.copyWith(
          reportSettings: updatedReportSettings,
          action: CompanySettingsAction.none,
          clearErrorMessage: true,
        ),
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('UpdateCompanyReportSettings error: $error');
        debugPrint('UpdateCompanyReportSettings stackTrace: $stackTrace');
      }

      emitState(
        actionState.copyWith(
          action: CompanySettingsAction.none,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to update report settings.',
          ),
        ),
      );
    }
  }
}
