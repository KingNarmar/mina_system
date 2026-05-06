import 'dart:typed_data';
import 'package:mina_system/features/company_settings/data/models/company_profile_model.dart';
import 'package:mina_system/features/company_settings/data/models/company_report_settings_model.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'report_pdf_formatters.dart';

class ReportPdfHeaderSection {
  static pw.Widget buildHeader({
    required ReportType reportType,
    required CompanyProfileModel companyProfile,
    required CompanyReportSettingsModel reportSettings,
    required Uint8List? logoBytes,
  }) {
    final logoImage = logoBytes == null ? null : pw.MemoryImage(logoBytes);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (reportSettings.showCompanyLogo && logoImage != null) ...[
              pw.Container(
                width: 72,
                height: 72,
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Image(logoImage, fit: pw.BoxFit.contain),
              ),
              pw.SizedBox(width: 16),
            ],
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    companyProfile.tradeName?.trim().isNotEmpty == true
                        ? companyProfile.tradeName!.trim()
                        : companyProfile.name,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blueGrey900,
                    ),
                  ),
                  if (reportSettings.showCompanyDetails) ...[
                    if (_hasText(companyProfile.legalName))
                      _buildSmallHeaderText(companyProfile.legalName!),
                    if (_hasText(companyProfile.addressLine1))
                      _buildSmallHeaderText(companyProfile.addressLine1!),
                    if (_hasText(companyProfile.addressLine2))
                      _buildSmallHeaderText(companyProfile.addressLine2!),
                    if (_hasText(companyProfile.city) ||
                        _hasText(companyProfile.country))
                      _buildSmallHeaderText(
                        [
                          companyProfile.city,
                          companyProfile.country,
                        ].where((item) => _hasText(item)).join(', '),
                      ),
                    if (_hasText(companyProfile.phone))
                      _buildSmallHeaderText('Phone: ${companyProfile.phone}'),
                    if (_hasText(companyProfile.email))
                      _buildSmallHeaderText('Email: ${companyProfile.email}'),
                    if (_hasText(companyProfile.website))
                      _buildSmallHeaderText(
                        'Website: ${companyProfile.website}',
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 18),
        pw.Container(height: 1, color: PdfColors.grey300),
        pw.SizedBox(height: 14),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Text(
                ReportPdfFormatters.getReportTitle(reportType),
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey900,
                ),
              ),
            ),
            if (reportSettings.showGeneratedBy)
              pw.Text(
                'Generated: ${ReportPdfFormatters.formatDate(DateTime.now())}',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.blueGrey600,
                ),
              ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSmallHeaderText(String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 3),
      child: pw.Text(
        value.trim(),
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.blueGrey700),
      ),
    );
  }

  static bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
