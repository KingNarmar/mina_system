import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
}
