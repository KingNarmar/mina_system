import 'package:mina_system/features/company_settings/data/models/company_report_settings_model.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportPdfResponsibilitySection {
  static pw.Widget buildResponsibilityStatement({
    required ReportType reportType,
    required CompanyReportSettingsModel reportSettings,
  }) {
    final statement = _getResponsibilityStatement(
      reportType: reportType,
      reportSettings: reportSettings,
    );

    if (statement == null || statement.trim().isEmpty) {
      return pw.SizedBox();
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 20),
      child: pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: PdfColors.grey300),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Responsibility Statement',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey900,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              statement.trim(),
              style: const pw.TextStyle(
                fontSize: 9,
                color: PdfColors.blueGrey700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String? _getResponsibilityStatement({
    required ReportType reportType,
    required CompanyReportSettingsModel reportSettings,
  }) {
    switch (reportType) {
      case ReportType.workerCustody:
        return reportSettings.custodyResponsibilityStatement;

      case ReportType.lostDamaged:
        return reportSettings.lossDamageResponsibilityStatement;

      case ReportType.toolHistory:
      case ReportType.transactions:
      case ReportType.toolSummary:
        return null;
    }
  }
}
