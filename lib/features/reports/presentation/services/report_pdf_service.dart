import 'dart:typed_data';

import 'package:mina_system/features/company_settings/data/models/company_profile_model.dart';
import 'package:mina_system/features/company_settings/data/models/company_report_settings_model.dart';
import 'package:mina_system/features/reports/data/models/report_filter_model.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';
import 'package:mina_system/features/reports/presentation/functions/report_filter_helpers.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/custody_balance_calculator.dart';
import 'package:mina_system/features/transactions/presentation/functions/tool_summary_calculator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportPdfService {
  ReportPdfService({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  static const String _companyAssetsBucket = 'company-assets';
  Future<Uint8List> buildReportPdf({
    required ReportType reportType,
    required ReportFilterModel filters,
    required List<TransactionModel> transactions,
    required CompanyProfileModel companyProfile,
    required CompanyReportSettingsModel reportSettings,
  }) async {
    final pdf = pw.Document();

    final logoBytes = await _loadCompanyLogoBytes(
      companyProfile: companyProfile,
      reportSettings: reportSettings,
    );

    final filteredTransactions = applyReportTransactionFilters(
      transactions: transactions,
      filters: filters,
      lostDamagedOnly: reportType == ReportType.lostDamaged,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            _buildHeader(
              reportType: reportType,
              companyProfile: companyProfile,
              reportSettings: reportSettings,
              logoBytes: logoBytes,
            ),
            pw.SizedBox(height: 16),
            _buildFiltersSummary(filters),
            pw.SizedBox(height: 20),
            _buildReportBody(
              reportType: reportType,
              transactions: filteredTransactions,
            ),
            pw.SizedBox(height: 24),
            _buildFooter(reportSettings),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader({
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
                _getReportTitle(reportType),
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey900,
                ),
              ),
            ),
            if (reportSettings.showGeneratedBy)
              pw.Text(
                'Generated: ${_formatDate(DateTime.now())}',
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

  pw.Widget _buildFiltersSummary(ReportFilterModel filters) {
    final rows = <String>[
      'Worker: ${filters.worker == null ? 'All' : '${filters.worker!.name} (${filters.worker!.hrCode})'}',
      'Tool: ${filters.tool == null ? 'All' : '${filters.tool!.toolName} (${filters.tool!.toolCode})'}',
      'Transaction Type: ${filters.transactionType == null ? 'All' : _getTransactionTypeLabel(filters.transactionType!)}',
      'Date From: ${filters.dateFrom == null ? 'Not selected' : _formatDate(filters.dateFrom!)}',
      'Date To: ${filters.dateTo == null ? 'Not selected' : _formatDate(filters.dateTo!)}',
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

  pw.Widget _buildReportBody({
    required ReportType reportType,
    required List<TransactionModel> transactions,
  }) {
    switch (reportType) {
      case ReportType.workerCustody:
        return _buildWorkerCustodyTable(transactions);

      case ReportType.toolSummary:
        return _buildToolSummaryTable(transactions);

      case ReportType.toolHistory:
      case ReportType.transactions:
      case ReportType.lostDamaged:
        return _buildTransactionsTable(transactions);
    }
  }

  pw.Widget _buildWorkerCustodyTable(List<TransactionModel> transactions) {
    final balances = calculateCustodyBalances(transactions);

    if (balances.isEmpty) {
      return _buildEmptyMessage('No open custody balances found.');
    }

    return pw.TableHelper.fromTextArray(
      headers: const ['Worker', 'HR Code', 'Tool', 'Qty', 'Unit'],
      data: balances.map((balance) {
        return [
          balance.workerName,
          balance.workerHrCode,
          balance.toolName,
          balance.balanceQuantity.toStringAsFixed(2),
          balance.unit,
        ];
      }).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(6),
    );
  }

  pw.Widget _buildToolSummaryTable(List<TransactionModel> transactions) {
    final summaries = calculateToolCustodySummaries(transactions);

    if (summaries.isEmpty) {
      return _buildEmptyMessage('No tool summary data found.');
    }

    return pw.TableHelper.fromTextArray(
      headers: const [
        'Tool',
        'Issued',
        'Returned',
        'Lost',
        'Damaged',
        'Open',
        'Unit',
      ],
      data: summaries.map((summary) {
        return [
          summary.toolName,
          summary.issuedQuantity.toStringAsFixed(2),
          summary.returnedQuantity.toStringAsFixed(2),
          summary.lostQuantity.toStringAsFixed(2),
          summary.damagedQuantity.toStringAsFixed(2),
          summary.openCustodyQuantity.toStringAsFixed(2),
          summary.unit,
        ];
      }).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(6),
    );
  }

  pw.Widget _buildTransactionsTable(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return _buildEmptyMessage('No matching transactions found.');
    }

    return pw.TableHelper.fromTextArray(
      headers: const ['Code', 'Type', 'Worker', 'Tool', 'Qty', 'Unit', 'Date'],
      data: transactions.map((transaction) {
        return [
          transaction.transactionCode,
          _getTransactionTypeLabel(transaction.type),
          transaction.workerName,
          transaction.toolName,
          transaction.quantity.toStringAsFixed(2),
          transaction.unit,
          _formatDate(transaction.dateTime),
        ];
      }).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(6),
    );
  }

  pw.Widget _buildFooter(CompanyReportSettingsModel reportSettings) {
    final footerText = reportSettings.reportFooterText?.trim();

    if (footerText == null || footerText.isEmpty) {
      return pw.SizedBox();
    }

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Text(
        footerText,
        textAlign: pw.TextAlign.center,
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.blueGrey600),
      ),
    );
  }

  pw.Widget _buildEmptyMessage(String message) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Text(message, style: const pw.TextStyle(fontSize: 11)),
    );
  }

  String _getReportTitle(ReportType reportType) {
    switch (reportType) {
      case ReportType.workerCustody:
        return 'Worker Custody Report';
      case ReportType.toolHistory:
        return 'Tool History Report';
      case ReportType.transactions:
        return 'Transactions Report';
      case ReportType.lostDamaged:
        return 'Lost & Damaged Report';
      case ReportType.toolSummary:
        return 'Tool Summary Report';
    }
  }

  String _getTransactionTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.issue:
        return 'Issue';
      case TransactionType.returnTool:
        return 'Return';
      case TransactionType.lost:
        return 'Lost';
      case TransactionType.damaged:
        return 'Damaged';
    }
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  Future<Uint8List?> _loadCompanyLogoBytes({
    required CompanyProfileModel companyProfile,
    required CompanyReportSettingsModel reportSettings,
  }) async {
    if (!reportSettings.showCompanyLogo) {
      return null;
    }

    final logoPath = companyProfile.logoPath;

    if (logoPath == null || logoPath.trim().isEmpty) {
      return null;
    }

    try {
      return await _supabase.storage
          .from(_companyAssetsBucket)
          .download(logoPath.trim());
    } catch (_) {
      return null;
    }
  }

  pw.Widget _buildSmallHeaderText(String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 3),
      child: pw.Text(
        value.trim(),
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.blueGrey700),
      ),
    );
  }

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
