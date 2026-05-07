import 'package:mina_system/features/company_settings/data/models/company_report_settings_model.dart';
import 'package:mina_system/features/reports/data/models/report_filter_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'report_pdf_formatters.dart';

class ReportPdfFiltersSection {
  static pw.Widget buildFiltersSummary({
    required ReportFilterModel filters,
    required CompanyReportSettingsModel reportSettings,
  }) {
    final rows = <String>[
      'Worker: ${filters.worker == null ? 'All' : '${filters.worker!.name} (${filters.worker!.hrCode})'}',
      'Tool: ${filters.tool == null ? 'All' : '${filters.tool!.toolName} (${filters.tool!.toolCode})'}',
      'Transaction Type: ${filters.transactionType == null ? 'All' : ReportPdfFormatters.getTransactionTypeLabel(filters.transactionType!)}',
      'Date From: ${filters.dateFrom == null ? 'Not selected' : ReportPdfFormatters.formatDate(filters.dateFrom!, dateFormat: reportSettings.dateFormat)}',
      'Date To: ${filters.dateTo == null ? 'Not selected' : ReportPdfFormatters.formatDate(filters.dateTo!, dateFormat: reportSettings.dateFormat)}',
    ];

    return pw.Container(
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
            'Filters',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          ...rows.map(
            (row) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Text(row, style: const pw.TextStyle(fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }
}
