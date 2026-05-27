import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/reports/data/models/signed_report_model.dart';
import 'package:mina_system/features/reports/data/repo/signed_reports_repo.dart';
import 'package:mina_system/features/reports/presentation/cubit/signed_reports_state.dart';
import 'package:url_launcher/url_launcher.dart';

class SignedReportsCubit extends Cubit<SignedReportsState> {
  SignedReportsCubit({SignedReportsRepo? signedReportsRepo})
    : _signedReportsRepo = signedReportsRepo ?? SignedReportsRepo(),
      super(const SignedReportsState());

  final SignedReportsRepo _signedReportsRepo;

  Future<void> loadSignedReports({
    required String companyId,
    String? searchTerm,
    String? reportType,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    try {
      final reports = await _signedReportsRepo.getSignedReports(
        companyId: companyId,
        searchTerm: searchTerm,
        reportType: reportType,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

      emit(
        state.copyWith(
          reports: reports,
          isLoading: false,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  Future<void> openSignedReport(SignedReportModel signedReport) async {
    emit(
      state.copyWith(openingReportId: signedReport.id, clearErrorMessage: true),
    );

    try {
      final signedUrl = await _signedReportsRepo.createSignedReportSignedUrl(
        signedReport: signedReport,
      );

      final uri = Uri.parse(signedUrl);

      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!opened) {
        throw StateError('Unable to open signed PDF.');
      }

      emit(state.copyWith(clearOpeningReportId: true, clearErrorMessage: true));
    } catch (error) {
      emit(
        state.copyWith(
          clearOpeningReportId: true,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
