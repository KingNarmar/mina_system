import 'package:mina_system/features/dashboard/data/models/dashboard_summary_model.dart';

class DashboardState {
  const DashboardState({
    required this.summary,
    this.isLoading = false,
    this.errorMessage,
  });

  final DashboardSummaryModel summary;
  final bool isLoading;
  final String? errorMessage;

  DashboardState copyWith({
    DashboardSummaryModel? summary,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return DashboardState(
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
