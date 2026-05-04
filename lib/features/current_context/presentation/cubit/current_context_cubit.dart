import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/create_company_request.dart';
import '../../data/repo/current_context_repo.dart';
import 'current_context_state.dart';

class CurrentContextCubit extends Cubit<CurrentContextState> {
  CurrentContextCubit({CurrentContextRepo? repo})
    : _repo = repo ?? CurrentContextRepo(),
      super(const CurrentContextInitial());

  final CurrentContextRepo _repo;

  Future<void> loadCurrentContext() async {
    emit(const CurrentContextLoading());

    try {
      final profile = await _repo.getCurrentProfile();
      final companies = await _repo.getCurrentUserCompanies(
        profileId: profile.id,
      );

      emit(
        CurrentContextLoaded(
          profile: profile,
          companies: companies,
          currentCompany: companies.length == 1 ? companies.first : null,
        ),
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('CurrentContext error: $error');
        debugPrint('CurrentContext stackTrace: $stackTrace');
      }

      emit(const CurrentContextFailure('Unable to load company context.'));
    }
  }

  Future<void> createCompany({required String companyName}) async {
    emit(const CurrentContextLoading());

    try {
      await _repo.createCompany(CreateCompanyRequest(companyName: companyName));

      await loadCurrentContext();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('CreateCompany error: $error');
        debugPrint('CreateCompany stackTrace: $stackTrace');
      }

      emit(const CurrentContextFailure('Unable to create company.'));
    }
  }

  void updateCurrentCompanyName(String companyName) {
    final currentState = state;

    if (currentState is! CurrentContextLoaded) {
      return;
    }

    final currentCompany = currentState.currentCompany;

    if (currentCompany == null) {
      return;
    }

    final updatedCurrentCompany = currentCompany.copyWith(name: companyName);

    final updatedCompanies = currentState.companies.map((company) {
      if (company.id == currentCompany.id) {
        return company.copyWith(name: companyName);
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
}
