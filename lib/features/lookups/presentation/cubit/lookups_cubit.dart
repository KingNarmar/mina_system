import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/services/network_status_service.dart';
import 'package:mina_system/core/utils/app_error_message.dart';
import 'package:mina_system/features/lookups/data/repo/lookups_repo.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit_helpers.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit_initial_data.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_state.dart';
import 'package:mina_system/features/lookups/presentation/functions/lookup_helpers.dart';

part 'lookups_cubit_departments.dart';
part 'lookups_cubit_job_titles.dart';
part 'lookups_cubit_tool_categories.dart';
part 'lookups_cubit_tool_units.dart';

class LookupsCubit extends Cubit<LookupsState> {
  LookupsCubit({
    LookupsRepo? lookupsRepo,
    NetworkStatusService? networkStatusService,
  }) : _lookupsRepo = lookupsRepo ?? LookupsRepo(),
       _networkStatusService = networkStatusService ?? NetworkStatusService(),
       super(
         const LookupsState(
           departments: LookupsCubitInitialData.initialDepartments,
           jobTitlesByDepartment:
               LookupsCubitInitialData.initialJobTitlesByDepartment,
           toolUnits: LookupsCubitInitialData.initialToolUnits,
           toolCategories: LookupsCubitInitialData.initialToolCategories,
         ),
       );

  final LookupsRepo _lookupsRepo;
  final NetworkStatusService _networkStatusService;

  void emitState(LookupsState state) => emit(state);

  Future<void> loadLookups({
    required String companyId,
    bool showLoader = true,
  }) async {
    if (showLoader) {
      emit(state.copyWith(isLoading: true, clearErrorMessage: true));
    } else {
      emit(state.copyWith(clearErrorMessage: true));
    }

    try {
      final departments = await _lookupsRepo.getDepartments(
        companyId: companyId,
      );

      final jobTitles = await _lookupsRepo.getJobTitles(companyId: companyId);

      final toolUnits = await _lookupsRepo.getToolUnits(companyId: companyId);

      final toolCategories = await _lookupsRepo.getToolCategories(
        companyId: companyId,
      );

      emit(
        LookupsCubitHelpers.buildStateFromModels(
          departments: departments,
          jobTitles: jobTitles,
          toolUnits: toolUnits,
          toolCategories: toolCategories,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to load lookups. Please try again.',
          ),
        ),
      );
    }
  }

  void clearErrorMessage() {
    if (state.errorMessage == null) {
      return;
    }

    emit(state.copyWith(clearErrorMessage: true));
  }

  Future<bool> _ensureOnline() async {
    try {
      await _networkStatusService.ensureOnline();
      return true;
    } on NetworkUnavailableException catch (error) {
      emit(state.copyWith(isSubmitting: false, errorMessage: error.message));
      return false;
    }
  }
}
