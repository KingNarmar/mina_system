import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/services/network_status_service.dart';

import '../../data/models/company_document_template_model.dart';
import '../../data/models/company_profile_model.dart';
import '../../data/models/company_report_settings_model.dart';
import '../../data/repo/company_settings_repo.dart';
import 'company_settings_state.dart';

class CompanySettingsCubit extends Cubit<CompanySettingsState> {
  CompanySettingsCubit({
    CompanySettingsRepo? repo,
    NetworkStatusService? networkStatusService,
  }) : _repo = repo ?? CompanySettingsRepo(),
       _networkStatusService = networkStatusService ?? NetworkStatusService(),
       super(const CompanySettingsInitial());

  final CompanySettingsRepo _repo;
  final NetworkStatusService _networkStatusService;

  Future<void> loadCompanyProfile({required String companyId}) async {
    emit(const CompanySettingsLoading());

    try {
      final profile = await _repo.getCompanyProfile(companyId: companyId);
      final reportSettings = await _repo.getCompanyReportSettings(
        companyId: companyId,
      );
      final documentTemplates = await _repo.getCompanyDocumentTemplates(
        companyId: companyId,
      );

      emit(
        CompanySettingsLoaded(
          profile: profile,
          reportSettings: reportSettings,
          documentTemplates: documentTemplates,
        ),
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

    final actionState = currentState.copyWith(
      action: CompanySettingsAction.updatingProfile,
      clearErrorMessage: true,
    );

    emit(actionState);

    final canContinue = await _ensureOnline(actionState);
    if (!canContinue) {
      return;
    }

    try {
      final updatedProfile = await _repo.updateCompanyProfile(profile: profile);

      emit(
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

      emit(
        actionState.copyWith(
          action: CompanySettingsAction.none,
          errorMessage: 'Unable to update company profile.',
        ),
      );
    }
  }

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

    emit(actionState);

    final canContinue = await _ensureOnline(actionState);
    if (!canContinue) {
      return;
    }

    try {
      final updatedReportSettings = await _repo.updateCompanyReportSettings(
        reportSettings: reportSettings,
      );

      emit(
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

      emit(
        actionState.copyWith(
          action: CompanySettingsAction.none,
          errorMessage: 'Unable to update report settings.',
        ),
      );
    }
  }

  Future<void> updateCompanyDocumentTemplate({
    required CompanyDocumentTemplateModel documentTemplate,
  }) async {
    final currentState = state;

    if (currentState is! CompanySettingsLoaded) {
      return;
    }

    final actionState = currentState.copyWith(
      action: CompanySettingsAction.updatingDocumentTemplate,
      clearErrorMessage: true,
    );

    emit(actionState);

    final canContinue = await _ensureOnline(actionState);
    if (!canContinue) {
      return;
    }

    try {
      final updatedDocumentTemplate = await _repo.updateCompanyDocumentTemplate(
        documentTemplate: documentTemplate,
      );

      final updatedDocumentTemplates = actionState.documentTemplates.map((
        item,
      ) {
        if (item.id == updatedDocumentTemplate.id) {
          return updatedDocumentTemplate;
        }

        return item;
      }).toList();

      emit(
        actionState.copyWith(
          documentTemplates: updatedDocumentTemplates,
          action: CompanySettingsAction.none,
          clearErrorMessage: true,
        ),
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('UpdateCompanyDocumentTemplate error: $error');
        debugPrint('UpdateCompanyDocumentTemplate stackTrace: $stackTrace');
      }

      emit(
        actionState.copyWith(
          action: CompanySettingsAction.none,
          errorMessage: 'Unable to update document template.',
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

    emit(actionState);

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

      emit(
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

      emit(
        actionState.copyWith(
          action: CompanySettingsAction.none,
          errorMessage: 'Unable to upload company logo.',
        ),
      );
    }
  }

  void clearErrorMessage() {
    final currentState = state;

    if (currentState is! CompanySettingsLoaded) {
      return;
    }

    if (currentState.errorMessage == null) {
      return;
    }

    emit(currentState.copyWith(clearErrorMessage: true));
  }

  Future<bool> _ensureOnline(CompanySettingsLoaded currentState) async {
    try {
      await _networkStatusService.ensureOnline();
      return true;
    } on NetworkUnavailableException catch (error) {
      emit(
        currentState.copyWith(
          action: CompanySettingsAction.none,
          errorMessage: error.message,
        ),
      );
      return false;
    }
  }
}
