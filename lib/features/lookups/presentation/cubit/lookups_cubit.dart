import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/lookups/data/repo/lookups_repo.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit_helpers.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit_initial_data.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_state.dart';
import 'package:mina_system/features/lookups/presentation/functions/lookup_helpers.dart';

part 'lookups_cubit_departments.dart';
part 'lookups_cubit_job_titles.dart';
part 'lookups_cubit_tool_units.dart';
part 'lookups_cubit_tool_categories.dart';

class LookupsCubit extends Cubit<LookupsState> {
  LookupsCubit({LookupsRepo? lookupsRepo})
    : _lookupsRepo = lookupsRepo ?? LookupsRepo(),
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

  void emitState(LookupsState state) => emit(state);

  Future<void> loadLookups({required String companyId}) async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

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
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }
}
