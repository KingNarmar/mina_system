import 'package:mina_system/core/theme/app_pdf_colors.dart';
import 'package:mina_system/features/company_settings/data/models/company_document_template_model.dart';
import 'package:mina_system/features/company_settings/data/models/company_report_settings_model.dart';
import 'package:pdf/widgets.dart' as pw;

import 'report_pdf_formatters.dart';

class ReportPdfDocumentControlSection {
  static pw.Widget buildDocumentControl({
    required CompanyReportSettingsModel reportSettings,
    required CompanyDocumentTemplateModel? documentTemplate,
  }) {
    if (!reportSettings.showDocumentControl || documentTemplate == null) {
      return pw.SizedBox();
    }

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: AppPdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: AppPdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Document Control',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: AppPdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            columnWidths: const {
              0: pw.FlexColumnWidth(1.2),
              1: pw.FlexColumnWidth(1.8),
              2: pw.FlexColumnWidth(1),
              3: pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                children: [
                  _buildDocumentControlCell(
                    label: 'Document Code',
                    value: documentTemplate.documentCode,
                  ),
                  _buildDocumentControlCell(
                    label: 'Document Title',
                    value: documentTemplate.documentTitle,
                  ),
                  _buildDocumentControlCell(
                    label: 'Issue No.',
                    value: documentTemplate.issueNo,
                  ),
                  _buildDocumentControlCell(
                    label: 'Revision',
                    value: documentTemplate.revisionNo,
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  _buildDocumentControlCell(
                    label: 'Effective Date',
                    value: ReportPdfFormatters.formatDate(
                      documentTemplate.effectiveDate,
                      timezone: reportSettings.defaultTimezone,
                      dateFormat: reportSettings.dateFormat,
                    ),
                  ),
                  _buildDocumentControlCell(
                    label: 'Report Type',
                    value: ReportPdfFormatters.formatTemplateReportType(
                      documentTemplate.reportType,
                    ),
                  ),
                  _buildDocumentControlCell(
                    label: 'Prepared By',
                    value: documentTemplate.preparedByTitle ?? '-',
                  ),
                  _buildDocumentControlCell(
                    label: 'Approved By',
                    value: documentTemplate.approvedByTitle ?? '-',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDocumentControlCell({
    required String label,
    required String value,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(right: 8, bottom: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 7,
              color: AppPdfColors.blueGrey500,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            value.trim().isEmpty ? '-' : value.trim(),
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: AppPdfColors.blueGrey900,
            ),
          ),
        ],
      ),
    );
  }
}
