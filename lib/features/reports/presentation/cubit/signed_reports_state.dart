import 'package:mina_system/features/reports/data/models/signed_report_model.dart';

class SignedReportsState {
  const SignedReportsState({
    this.reports = const [],
    this.isLoading = false,
    this.openingReportId,
    this.errorMessage,
  });

  final List<SignedReportModel> reports;
  final bool isLoading;
  final String? openingReportId;
  final String? errorMessage;

  bool get hasReports => reports.isNotEmpty;

  bool get isInitialLoading => isLoading && reports.isEmpty;

  bool get isRefreshing => isLoading && reports.isNotEmpty;

  bool get isOpening => openingReportId != null;

  bool isOpeningReport(String reportId) {
    return openingReportId == reportId;
  }

  SignedReportsState copyWith({
    List<SignedReportModel>? reports,
    bool? isLoading,
    String? openingReportId,
    String? errorMessage,
    bool clearOpeningReportId = false,
    bool clearErrorMessage = false,
  }) {
    return SignedReportsState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      openingReportId: clearOpeningReportId
          ? null
          : openingReportId ?? this.openingReportId,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
