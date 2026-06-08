import 'dart:typed_data';

import 'package:mina_system/features/company_settings/data/models/company_document_template_model.dart';
import 'package:mina_system/features/company_settings/data/models/company_profile_model.dart';
import 'package:mina_system/features/company_settings/data/models/company_report_settings_model.dart';
import 'package:mina_system/features/reports/data/models/report_filter_model.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';
import 'package:mina_system/features/reports/presentation/functions/report_filter_helpers.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pdf/report_pdf_assets_loader.dart';
import 'pdf/report_pdf_document_control_section.dart';
import 'pdf/report_pdf_filters_section.dart';
import 'pdf/report_pdf_footer_section.dart';
import 'pdf/report_pdf_header_section.dart';
import 'pdf/report_pdf_responsibility_section.dart';
import 'pdf/report_pdf_signature_section.dart';
import 'pdf/report_pdf_tables_section.dart';
import 'pdf/report_pdf_template_matcher.dart';

class ReportPdfService {
  ReportPdfService({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  static const int _maxReportPages = 200;

  static const double _minimumSignatureSectionFreeSpace = 190;

  final SupabaseClient _supabase;

  Future<Uint8List> buildReportPdf({
    required ReportType reportType,
    required ReportFilterModel filters,
    required List<TransactionModel> transactions,
    required CompanyProfileModel companyProfile,
    required CompanyReportSettingsModel reportSettings,
    required List<CompanyDocumentTemplateModel> documentTemplates,
    Uint8List? workerSignatureBytes,
    DateTime? signedAt,
  }) async {
    final pdf = pw.Document();

    final logoBytes = await ReportPdfAssetsLoader.loadCompanyLogoBytes(
      supabase: _supabase,
      companyProfile: companyProfile,
      reportSettings: reportSettings,
    );

    final documentTemplate = ReportPdfTemplateMatcher.findDocumentTemplate(
      reportType: reportType,
      documentTemplates: documentTemplates,
    );

    final shouldShowDocumentControl =
        reportSettings.showDocumentControl && documentTemplate != null;

    final shouldShowDemoWatermark = _shouldShowDemoWatermark(
      companyProfile: companyProfile,
      reportSettings: reportSettings,
    );

    final filteredTransactions = applyReportTransactionFilters(
      transactions: transactions,
      filters: filters,
      lostDamagedOnly:
          reportType == ReportType.lostDamaged ||
          reportType == ReportType.lostDamagedApproval,
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          buildForeground: shouldShowDemoWatermark
              ? (_) => _buildDemoWatermark()
              : null,
        ),
        maxPages: _maxReportPages,
        footer: ReportPdfFooterSection.buildPageNumberFooter,
        build: (context) {
          return [
            ReportPdfHeaderSection.buildHeader(
              reportType: reportType,
              companyProfile: companyProfile,
              reportSettings: reportSettings,
              logoBytes: logoBytes,
            ),
            if (shouldShowDemoWatermark) ...[
              pw.SizedBox(height: 10),
              _buildDemoNoticeBanner(),
            ],
            if (shouldShowDocumentControl) ...[
              pw.SizedBox(height: 16),
              ReportPdfDocumentControlSection.buildDocumentControl(
                reportSettings: reportSettings,
                documentTemplate: documentTemplate,
              ),
            ],
            pw.SizedBox(height: 16),
            ReportPdfFiltersSection.buildFiltersSummary(
              filters: filters,
              reportSettings: reportSettings,
            ),
            pw.SizedBox(height: 20),
            ReportPdfTablesSection.buildReportBody(
              reportType: reportType,
              transactions: filteredTransactions,
              reportSettings: reportSettings,
            ),
            ReportPdfResponsibilitySection.buildResponsibilityStatement(
              reportType: reportType,
              reportSettings: reportSettings,
            ),
            if (documentTemplate != null) ...[
              pw.NewPage(freeSpace: _minimumSignatureSectionFreeSpace),
              pw.SizedBox(height: 20),
              ReportPdfSignatureSection.buildSignatureSection(
                documentTemplate,
                workerSignatureBytes: workerSignatureBytes,
                signedAt: signedAt,
                timezone: reportSettings.defaultTimezone,
                dateFormat: reportSettings.dateFormat,
              ),
            ],
            pw.SizedBox(height: 24),
            ReportPdfFooterSection.buildFooter(reportSettings),
          ];
        },
      ),
    );

    return pdf.save();
  }

  bool _shouldShowDemoWatermark({
    required CompanyProfileModel companyProfile,
    required CompanyReportSettingsModel reportSettings,
  }) {
    final companyId = companyProfile.id.trim().toLowerCase();
    final reportSettingsId = reportSettings.id.trim().toLowerCase();

    return companyId == 'demo-company-001' ||
        reportSettingsId.startsWith('demo-');
  }

  pw.Widget _buildDemoWatermark() {
    return pw.FullPage(
      ignoreMargins: true,
      child: pw.Center(
        child: pw.Opacity(
          opacity: 0.16,
          child: pw.Transform.rotate(
            angle: -0.55,
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  'DEMO',
                  style: pw.TextStyle(
                    fontSize: 96,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'SAMPLE DATA ONLY',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 2,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  pw.Widget _buildDemoNoticeBanner() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: pw.BoxDecoration(
        color: PdfColors.amber50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.amber300),
      ),
      child: pw.Text(
        'DEMO MODE — This report is generated from local sample data only and is not an official custody document.',
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.amber900,
        ),
      ),
    );
  }
}
