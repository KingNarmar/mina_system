import 'package:mina_system/features/company_settings/data/models/company_report_settings_model.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/custody_balance_calculator.dart';
import 'package:mina_system/features/transactions/presentation/functions/tool_summary_calculator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'report_pdf_formatters.dart';

class ReportPdfTablesSection {
  static pw.Widget buildReportBody({
    required ReportType reportType,
    required List<TransactionModel> transactions,
    required CompanyReportSettingsModel reportSettings,
  }) {
    switch (reportType) {
      case ReportType.workerCustody:
        return _buildWorkerCustodyTable(transactions);

      case ReportType.toolSummary:
        return _buildToolSummaryTable(transactions);

      case ReportType.lostDamagedApproval:
        return _buildLostDamagedApprovalForm(
          transactions: transactions,
          reportSettings: reportSettings,
        );

      case ReportType.toolHistory:
      case ReportType.transactions:
      case ReportType.lostDamaged:
        return _buildTransactionsTable(
          transactions: transactions,
          reportSettings: reportSettings,
        );
    }
  }

  static pw.Widget _buildWorkerCustodyTable(
    List<TransactionModel> transactions,
  ) {
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

  static pw.Widget _buildToolSummaryTable(List<TransactionModel> transactions) {
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

  static pw.Widget _buildTransactionsTable({
    required List<TransactionModel> transactions,
    required CompanyReportSettingsModel reportSettings,
  }) {
    if (transactions.isEmpty) {
      return _buildEmptyMessage('No matching transactions found.');
    }

    return pw.TableHelper.fromTextArray(
      headers: const [
        'Code',
        'Type',
        'Approval',
        'Worker',
        'Tool',
        'Qty',
        'Unit',
        'Date',
      ],
      data: transactions.map((transaction) {
        return [
          transaction.transactionCode,
          ReportPdfFormatters.getTransactionTypeLabel(transaction.type),
          ReportPdfFormatters.getApprovalStatusLabel(transaction),
          transaction.workerName,
          transaction.toolName,
          transaction.quantity.toStringAsFixed(2),
          transaction.unit,
          ReportPdfFormatters.formatDate(
            transaction.dateTime,
            dateFormat: reportSettings.dateFormat,
          ),
        ];
      }).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(5),
    );
  }

  static pw.Widget _buildLostDamagedApprovalForm({
    required List<TransactionModel> transactions,
    required CompanyReportSettingsModel reportSettings,
  }) {
    if (transactions.isEmpty) {
      return _buildEmptyMessage(
        'No matching lost or damaged approval transactions found.',
      );
    }

    return pw.ListView(
      children: [
        for (final transaction in transactions) ...[
          _buildApprovalFormHeader(transaction),
          pw.SizedBox(height: 10),
          _buildSectionTitle('1. Transaction Summary'),
          pw.SizedBox(height: 6),
          _buildTwoColumnDetails([
            _PdfDetailItem(
              label: 'Transaction Code',
              value: transaction.transactionCode,
            ),
            _PdfDetailItem(
              label: 'Type',
              value: ReportPdfFormatters.getTransactionTypeLabel(
                transaction.type,
              ),
            ),
            _PdfDetailItem(
              label: 'Date',
              value: ReportPdfFormatters.formatDate(
                transaction.dateTime,
                dateFormat: reportSettings.dateFormat,
              ),
            ),
            _PdfDetailItem(
              label: 'Quantity',
              value:
                  '${_formatQuantity(transaction.quantity)} ${transaction.unit}',
            ),
            _PdfDetailItem(
              label: 'Approval Status',
              value: ReportPdfFormatters.getApprovalStatusLabel(transaction),
            ),
            _PdfDetailItem(
              label: 'Settlement Status',
              value: ReportPdfFormatters.getSettlementStatusValueLabel(
                transaction.settlementStatus,
              ),
            ),
          ]),
          pw.SizedBox(height: 10),
          _buildSectionTitle('2. Worker Information'),
          pw.SizedBox(height: 6),
          _buildTwoColumnDetails([
            _PdfDetailItem(label: 'Worker Name', value: transaction.workerName),
            _PdfDetailItem(label: 'HR Code', value: transaction.workerHrCode),
            _PdfDetailItem(
              label: 'Department',
              value: transaction.workerDepartment,
            ),
            _PdfDetailItem(
              label: 'Job Title',
              value: transaction.workerJobTitle,
            ),
          ]),
          pw.SizedBox(height: 10),
          _buildSectionTitle('3. Tool Information'),
          pw.SizedBox(height: 6),
          _buildTwoColumnDetails([
            _PdfDetailItem(label: 'Tool Name', value: transaction.toolName),
            _PdfDetailItem(label: 'Tool Code', value: transaction.toolCode),
            _PdfDetailItem(label: 'Unit', value: transaction.unit),
            _PdfDetailItem(label: 'Category', value: transaction.toolCategory),
          ]),
          pw.SizedBox(height: 10),
          _buildSectionTitle('4. Incident Reason / Note'),
          pw.SizedBox(height: 6),
          _buildTextBox(
            _hasText(transaction.note)
                ? _limitText(transaction.note!.trim(), maxLength: 450)
                : 'No incident note was added.',
            minHeight: 42,
          ),
          pw.SizedBox(height: 10),
          _buildSectionTitle('5. Evidence & Documents'),
          pw.SizedBox(height: 6),
          _buildTwoColumnDetails([
            _PdfDetailItem(
              label: 'Proof Image',
              value: _hasText(transaction.imagePath)
                  ? 'Attached'
                  : 'Not Attached',
            ),
            _PdfDetailItem(
              label: 'Signed Approval Document',
              value: _hasText(transaction.approvalDocumentPath)
                  ? 'Uploaded'
                  : 'Not Uploaded',
            ),
          ]),
          pw.SizedBox(height: 10),
          _buildSectionTitle('6. Approval Decision'),
          pw.SizedBox(height: 6),
          _buildDecisionBox(transaction),
          pw.SizedBox(height: 16),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 12),
        ],
      ],
    );
  }

  static pw.Widget _buildApprovalFormHeader(TransactionModel transaction) {
    final typeLabel = ReportPdfFormatters.getTransactionTypeLabel(
      transaction.type,
    );

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: pw.BoxDecoration(
        color: PdfColors.blueGrey800,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              '$typeLabel Tool Approval Form',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.Text(
            transaction.transactionCode,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 9.5,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blueGrey900,
        ),
      ),
    );
  }

  static pw.Widget _buildTwoColumnDetails(List<_PdfDetailItem> items) {
    final rows = <pw.TableRow>[];

    for (var index = 0; index < items.length; index += 2) {
      final first = items[index];
      final second = index + 1 < items.length ? items[index + 1] : null;

      rows.add(
        pw.TableRow(
          children: [_buildDetailCell(first), _buildDetailCell(second)],
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: const {0: pw.FlexColumnWidth(1), 1: pw.FlexColumnWidth(1)},
      children: rows,
    );
  }

  static pw.Widget _buildDetailCell(_PdfDetailItem? item) {
    if (item == null) {
      return pw.SizedBox();
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            item.label,
            style: const pw.TextStyle(
              fontSize: 7,
              color: PdfColors.blueGrey500,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            _cleanValue(item.value),
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTextBox(String text, {double minHeight = 38}) {
    return pw.Container(
      width: double.infinity,
      constraints: pw.BoxConstraints(minHeight: minHeight),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.blueGrey800),
      ),
    );
  }

  static pw.Widget _buildDecisionBox(TransactionModel transaction) {
    final decisionNote = _hasText(transaction.approvalDecisionNote)
        ? _limitText(transaction.approvalDecisionNote!.trim(), maxLength: 300)
        : '';

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              _buildCheckBox(
                label: 'Approved',
                checked: transaction.isApprovalApproved,
              ),
              pw.SizedBox(width: 16),
              _buildCheckBox(
                label: 'Rejected',
                checked: transaction.isApprovalRejected,
              ),
              pw.SizedBox(width: 16),
              _buildCheckBox(
                label: 'Pending Review',
                checked: transaction.isApprovalPending,
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Manager Decision Note:',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 4),
          _buildTextBox(decisionNote, minHeight: 32),
          pw.SizedBox(height: 8),
          pw.Row(
            children: [
              pw.Expanded(child: _buildSignatureLine('Manager Signature')),
              pw.SizedBox(width: 16),
              pw.Expanded(child: _buildSignatureLine('Date')),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCheckBox({
    required String label,
    required bool checked,
  }) {
    return pw.Row(
      children: [
        pw.Container(
          width: 9,
          height: 9,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.blueGrey700),
          ),
          child: checked
              ? pw.Center(
                  child: pw.Text(
                    'X',
                    style: pw.TextStyle(
                      fontSize: 6,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                )
              : pw.SizedBox(),
        ),
        pw.SizedBox(width: 5),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.blueGrey800),
        ),
      ],
    );
  }

  static pw.Widget _buildSignatureLine(String label) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 20),
        pw.Container(height: 0.7, color: PdfColors.blueGrey500),
        pw.SizedBox(height: 3),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 7, color: PdfColors.blueGrey600),
        ),
      ],
    );
  }

  static pw.Widget _buildEmptyMessage(String message) {
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

  static bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  static String _cleanValue(String? value) {
    final cleanValue = value?.trim();

    if (cleanValue == null || cleanValue.isEmpty) {
      return '-';
    }

    return cleanValue;
  }

  static String _formatQuantity(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  static String _limitText(String value, {required int maxLength}) {
    if (value.length <= maxLength) {
      return value;
    }

    return '${value.substring(0, maxLength)}...';
  }
}

class _PdfDetailItem {
  const _PdfDetailItem({required this.label, required this.value});

  final String label;
  final String? value;
}
