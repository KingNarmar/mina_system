import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/services/network_status_service.dart';
import 'package:mina_system/core/utils/app_error_message.dart';

import '../../data/models/company_model.dart';
import '../../data/models/create_company_request.dart';
import '../../data/repo/current_context_repo.dart';
import '../../data/services/current_company_storage_service.dart';
import 'current_context_state.dart';

class CurrentContextCubit extends Cubit<CurrentContextState> {
  CurrentContextCubit({
    CurrentContextRepo? repo,
    CurrentCompanyStorageService? currentCompanyStorageService,
    NetworkStatusService? networkStatusService,
  }) : _repo = repo ?? CurrentContextRepo(),
       _currentCompanyStorageService =
           currentCompanyStorageService ?? const CurrentCompanyStorageService(),
       _networkStatusService = networkStatusService ?? NetworkStatusService(),
       super(const CurrentContextInitial());

  final CurrentContextRepo _repo;
  final CurrentCompanyStorageService _currentCompanyStorageService;
  final NetworkStatusService _networkStatusService;

  Future<void> loadCurrentContext({
    bool restoreLastSelectedCompany = true,
  }) async {
    emit(const CurrentContextLoading());

    try {
      await _networkStatusService.ensureOnline();

      final profile = await _repo.getCurrentProfile();
      final companies = await _repo.getCurrentUserCompanies(
        profileId: profile.id,
      );

      final currentCompany = await _resolveCurrentCompany(
        profileId: profile.id,
        companies: companies,
        restoreLastSelectedCompany: restoreLastSelectedCompany,
      );

      emit(
        CurrentContextLoaded(
          profile: profile,
          companies: companies,
          currentCompany: currentCompany,
        ),
      );
    } on NetworkUnavailableException catch (error) {
      emit(CurrentContextFailure(error.message));
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('CurrentContext error: $error');
        debugPrint('CurrentContext stackTrace: $stackTrace');
      }

      emit(
        CurrentContextFailure(
          AppErrorMessage.fromError(
            error,
            fallback: 'Unable to load company context.',
          ),
        ),
      );
    }
  }

  Future<void> createCompany({required CreateCompanyRequest request}) async {
    emit(const CurrentContextLoading());

    try {
      await _networkStatusService.ensureOnline();

      await _repo.createCompany(request);

      await loadCurrentContext();
    } on NetworkUnavailableException catch (error) {
      emit(CurrentContextFailure(error.message));
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('CreateCompany error: $error');
        debugPrint('CreateCompany stackTrace: $stackTrace');
      }

      emit(
        CurrentContextFailure(
          AppErrorMessage.fromError(
            error,
            fallback: 'Unable to create company.',
          ),
        ),
      );
    }
  }

  Future<void> selectCurrentCompany({required String companyId}) async {
    final currentState = state;

    if (currentState is! CurrentContextLoaded) {
      return;
    }

    final selectedCompany = _findCompanyById(
      companies: currentState.companies,
      companyId: companyId,
    );

    if (selectedCompany == null) {
      return;
    }

    await _currentCompanyStorageService.saveLastSelectedCompanyId(
      profileId: currentState.profile.id,
      companyId: selectedCompany.id,
    );

    emit(
      CurrentContextLoaded(
        profile: currentState.profile,
        companies: currentState.companies,
        currentCompany: selectedCompany,
      ),
    );
  }

  void openCompanySelection() {
    final currentState = state;

    if (currentState is! CurrentContextLoaded) {
      return;
    }

    if (!currentState.hasMultipleCompanies) {
      return;
    }

    emit(
      CurrentContextLoaded(
        profile: currentState.profile,
        companies: currentState.companies,
        currentCompany: null,
      ),
    );
  }

  void updateCurrentCompanyProfile({
    required String companyName,
    required String timezone,
  }) {
    final currentState = state;

    if (currentState is! CurrentContextLoaded) {
      return;
    }

    final currentCompany = currentState.currentCompany;

    if (currentCompany == null) {
      return;
    }

    final updatedCurrentCompany = currentCompany.copyWith(
      name: companyName,
      timezone: timezone,
    );

    final updatedCompanies = currentState.companies.map((company) {
      if (company.id == currentCompany.id) {
        return company.copyWith(name: companyName, timezone: timezone);
      }

      return company;
    }).toList();

    emit(
      CurrentContextLoaded(
        profile: currentState.profile,
        companies: updatedCompanies,
        currentCompany: updatedCurrentCompany,
      ),
    );
  }

  Future<CompanyModel?> _resolveCurrentCompany({
    required String profileId,
    required List<CompanyModel> companies,
    required bool restoreLastSelectedCompany,
  }) async {
    if (companies.isEmpty) {
      await _currentCompanyStorageService.clearLastSelectedCompanyId(
        profileId: profileId,
      );

      return null;
    }

    if (companies.length == 1) {
      final onlyCompany = companies.first;

      await _currentCompanyStorageService.saveLastSelectedCompanyId(
        profileId: profileId,
        companyId: onlyCompany.id,
      );

      return onlyCompany;
    }

    if (!restoreLastSelectedCompany) {
      return null;
    }

    final lastSelectedCompanyId = await _currentCompanyStorageService
        .getLastSelectedCompanyId(profileId: profileId);

    if (lastSelectedCompanyId == null) {
      return null;
    }

    final savedCompany = _findCompanyById(
      companies: companies,
      companyId: lastSelectedCompanyId,
    );

    if (savedCompany == null) {
      await _currentCompanyStorageService.clearLastSelectedCompanyId(
        profileId: profileId,
      );

      return null;
    }

    return savedCompany;
  }

  CompanyModel? _findCompanyById({
    required List<CompanyModel> companies,
    required String companyId,
  }) {
    for (final company in companies) {
      if (company.id == companyId) {
        return company;
      }
    }

    return null;
  }
}
