import 'dart:typed_data';

import 'package:mina_system/core/theme/app_pdf_colors.dart';
import 'package:mina_system/features/company_settings/data/models/company_document_template_model.dart';
import 'package:pdf/widgets.dart' as pw;

import 'report_pdf_formatters.dart';

class ReportPdfSignatureSection {
  static pw.Widget buildSignatureSection(
    CompanyDocumentTemplateModel documentTemplate, {
    Uint8List? workerSignatureBytes,
    DateTime? signedAt,
    String? timezone,
    String? dateFormat,
  }) {
    final signatureLabels = <String>[
      ReportPdfFormatters.getSignatureLabel(
        label: documentTemplate.workerSignatureLabel,
        fallback: 'Worker Signature',
      ),
      ReportPdfFormatters.getSignatureLabel(
        label: documentTemplate.managerSignatureLabel,
        fallback: 'Manager Signature',
      ),
      ReportPdfFormatters.getSignatureLabel(
        label: documentTemplate.storekeeperSignatureLabel,
        fallback: 'Storekeeper Signature',
      ),
    ];

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: AppPdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Signatures',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: AppPdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 18),
          pw.Table(
            columnWidths: const {
              0: pw.FlexColumnWidth(1),
              1: pw.FlexColumnWidth(1),
              2: pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                children: [
                  _buildSignatureBox(
                    label: signatureLabels[0],
                    signatureBytes: workerSignatureBytes,
                    signedAt: signedAt,
                    timezone: timezone,
                    dateFormat: dateFormat,
                  ),
                  _buildSignatureBox(label: signatureLabels[1]),
                  _buildSignatureBox(label: signatureLabels[2]),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSignatureBox({
    required String label,
    Uint8List? signatureBytes,
    DateTime? signedAt,
    String? timezone,
    String? dateFormat,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(right: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: AppPdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 6),
          _buildSignatureImageOrLine(signatureBytes),
          pw.SizedBox(height: 5),
          pw.Text(
            'Signature',
            style: const pw.TextStyle(
              fontSize: 7,
              color: AppPdfColors.blueGrey500,
            ),
          ),
          pw.SizedBox(height: 16),
          _buildDateLine(signedAt, timezone: timezone, dateFormat: dateFormat),
          pw.SizedBox(height: 5),
          pw.Text(
            'Date',
            style: const pw.TextStyle(
              fontSize: 7,
              color: AppPdfColors.blueGrey500,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSignatureImageOrLine(Uint8List? signatureBytes) {
    if (signatureBytes == null || signatureBytes.isEmpty) {
      return pw.Column(
        children: [
          pw.SizedBox(height: 28),
          pw.Container(height: 1, color: AppPdfColors.grey500),
        ],
      );
    }

    return pw.Container(
      height: 36,
      alignment: pw.Alignment.bottomLeft,
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: AppPdfColors.grey500, width: 1),
        ),
      ),
      child: pw.Image(
        pw.MemoryImage(signatureBytes),
        height: 32,
        fit: pw.BoxFit.contain,
      ),
    );
  }

  static pw.Widget _buildDateLine(
    DateTime? signedAt, {
    String? timezone,
    String? dateFormat,
  }) {
    final formattedDate = signedAt == null
        ? null
        : ReportPdfFormatters.formatDate(
            signedAt,
            timezone: timezone,
            dateFormat: dateFormat,
          );

    if (formattedDate == null) {
      return pw.Container(height: 1, color: AppPdfColors.grey500);
    }

    return pw.Container(
      height: 14,
      alignment: pw.Alignment.bottomLeft,
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: AppPdfColors.grey500, width: 1),
        ),
      ),
      child: pw.Text(
        formattedDate,
        style: const pw.TextStyle(fontSize: 8, color: AppPdfColors.blueGrey900),
      ),
    );
  }
}
