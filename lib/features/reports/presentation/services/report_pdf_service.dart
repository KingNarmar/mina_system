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

    final filteredTransactions = applyReportTransactionFilters(
      transactions: transactions,
      filters: filters,
      lostDamagedOnly:
          reportType == ReportType.lostDamaged ||
          reportType == ReportType.lostDamagedApproval,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
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
              pw.SizedBox(height: 20),
              ReportPdfSignatureSection.buildSignatureSection(
                documentTemplate,
                workerSignatureBytes: workerSignatureBytes,
                signedAt: signedAt,
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
}
