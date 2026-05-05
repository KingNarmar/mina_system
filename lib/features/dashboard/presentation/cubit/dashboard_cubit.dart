import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/dashboard/data/models/dashboard_summary_model.dart';
import 'package:mina_system/features/dashboard/data/repo/dashboard_repo.dart';
import 'package:mina_system/features/dashboard/presentation/cubit/dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({DashboardRepo? dashboardRepo})
    : _dashboardRepo = dashboardRepo ?? DashboardRepo(),
      super(DashboardState(summary: DashboardSummaryModel.empty()));

  final DashboardRepo _dashboardRepo;

  Future<void> loadDashboardSummary({required String companyId}) async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    try {
      final summary = await _dashboardRepo.getDashboardSummary(
        companyId: companyId,
      );

      emit(
        state.copyWith(
          summary: summary,
          isLoading: false,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }
}
