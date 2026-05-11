import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/services/network_status_service.dart';
import 'package:mina_system/core/utils/app_error_message.dart';

import '../../data/models/company_document_template_model.dart';
import '../../data/models/company_profile_model.dart';
import '../../data/models/company_report_settings_model.dart';
import '../../data/repo/company_settings_repo.dart';
import 'company_settings_state.dart';

part 'company_settings_cubit_documents.dart';
part 'company_settings_cubit_profile.dart';
part 'company_settings_cubit_reports.dart';

class CompanySettingsCubit extends Cubit<CompanySettingsState> {
  CompanySettingsCubit({
    CompanySettingsRepo? repo,
    NetworkStatusService? networkStatusService,
  }) : _repo = repo ?? CompanySettingsRepo(),
       _networkStatusService = networkStatusService ?? NetworkStatusService(),
       super(const CompanySettingsInitial());

  final CompanySettingsRepo _repo;
  final NetworkStatusService _networkStatusService;

  void emitState(CompanySettingsState state) => emit(state);

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

      emit(
        CompanySettingsFailure(
          AppErrorMessage.fromError(
            error,
            fallback: 'Unable to load company profile.',
          ),
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
