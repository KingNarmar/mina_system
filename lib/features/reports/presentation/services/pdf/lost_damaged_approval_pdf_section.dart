import 'package:mina_system/features/company_settings/data/models/company_report_settings_model.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'report_pdf_empty_message.dart';
import 'report_pdf_formatters.dart';
import 'report_pdf_table_helpers.dart';

pw.Widget buildLostDamagedApprovalPdfSection({
  required List<TransactionModel> transactions,
  required CompanyReportSettingsModel reportSettings,
}) {
  if (transactions.isEmpty) {
    return buildReportPdfEmptyMessage(
      'No matching lost or damaged approval transactions found.',
    );
  }

  return pw.ListView(
    children: [
      for (final transaction in transactions) ...[
        _buildApprovalFormHeader(transaction),
        pw.SizedBox(height: 10),
        ReportPdfTableHelpers.buildSectionTitle('1. Transaction Summary'),
        pw.SizedBox(height: 6),
        ReportPdfTableHelpers.buildTwoColumnDetails([
          PdfDetailItem(
            label: 'Transaction Code',
            value: transaction.transactionCode,
          ),
          PdfDetailItem(
            label: 'Type',
            value: ReportPdfFormatters.getTransactionTypeLabel(
              transaction.type,
            ),
          ),
          PdfDetailItem(
            label: 'Date',
            value: ReportPdfFormatters.formatDate(
              transaction.dateTime,
              dateFormat: reportSettings.dateFormat,
            ),
          ),
          PdfDetailItem(
            label: 'Quantity',
            value:
                '${ReportPdfTableHelpers.formatPdfQuantity(transaction.quantity)} ${transaction.unit}',
          ),
          PdfDetailItem(
            label: 'Approval Status',
            value: ReportPdfFormatters.getApprovalStatusLabel(transaction),
          ),
          PdfDetailItem(
            label: 'Settlement Status',
            value: ReportPdfFormatters.getSettlementStatusValueLabel(
              transaction.settlementStatus,
            ),
          ),
        ]),
        pw.SizedBox(height: 10),
        ReportPdfTableHelpers.buildSectionTitle('2. Worker Information'),
        pw.SizedBox(height: 6),
        ReportPdfTableHelpers.buildTwoColumnDetails([
          PdfDetailItem(label: 'Worker Name', value: transaction.workerName),
          PdfDetailItem(label: 'HR Code', value: transaction.workerHrCode),
          PdfDetailItem(
            label: 'Department',
            value: transaction.workerDepartment,
          ),
          PdfDetailItem(label: 'Job Title', value: transaction.workerJobTitle),
        ]),
        pw.SizedBox(height: 10),
        ReportPdfTableHelpers.buildSectionTitle('3. Tool Information'),
        pw.SizedBox(height: 6),
        ReportPdfTableHelpers.buildTwoColumnDetails([
          PdfDetailItem(label: 'Tool Name', value: transaction.toolName),
          PdfDetailItem(label: 'Tool Code', value: transaction.toolCode),
          PdfDetailItem(label: 'Unit', value: transaction.unit),
          PdfDetailItem(label: 'Category', value: transaction.toolCategory),
        ]),
        pw.SizedBox(height: 10),
        ReportPdfTableHelpers.buildSectionTitle('4. Incident Reason / Note'),
        pw.SizedBox(height: 6),
        ReportPdfTableHelpers.buildTextBox(
          ReportPdfTableHelpers.hasPdfText(transaction.note)
              ? ReportPdfTableHelpers.limitPdfText(
                  transaction.note!.trim(),
                  maxLength: 450,
                )
              : 'No incident note was added.',
          minHeight: 42,
        ),
        pw.SizedBox(height: 10),
        ReportPdfTableHelpers.buildSectionTitle('5. Evidence & Documents'),
        pw.SizedBox(height: 6),
        ReportPdfTableHelpers.buildTwoColumnDetails([
          PdfDetailItem(
            label: 'Proof Image',
            value: ReportPdfTableHelpers.hasPdfText(transaction.imagePath)
                ? 'Attached'
                : 'Not Attached',
          ),
          PdfDetailItem(
            label: 'Signed Approval Document',
            value:
                ReportPdfTableHelpers.hasPdfText(
                  transaction.approvalDocumentPath,
                )
                ? 'Uploaded'
                : 'Not Uploaded',
          ),
        ]),
        pw.SizedBox(height: 10),
        ReportPdfTableHelpers.buildSectionTitle('6. Approval Decision'),
        pw.SizedBox(height: 6),
        _buildDecisionBox(transaction),
        pw.SizedBox(height: 16),
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 12),
      ],
    ],
  );
}

pw.Widget _buildApprovalFormHeader(TransactionModel transaction) {
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

pw.Widget _buildDecisionBox(TransactionModel transaction) {
  final decisionNote =
      ReportPdfTableHelpers.hasPdfText(transaction.approvalDecisionNote)
      ? ReportPdfTableHelpers.limitPdfText(
          transaction.approvalDecisionNote!.trim(),
          maxLength: 300,
        )
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
            ReportPdfTableHelpers.buildCheckBox(
              label: 'Approved',
              checked: transaction.isApprovalApproved,
            ),
            pw.SizedBox(width: 16),
            ReportPdfTableHelpers.buildCheckBox(
              label: 'Rejected',
              checked: transaction.isApprovalRejected,
            ),
            pw.SizedBox(width: 16),
            ReportPdfTableHelpers.buildCheckBox(
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
        ReportPdfTableHelpers.buildTextBox(decisionNote, minHeight: 32),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            pw.Expanded(
              child: ReportPdfTableHelpers.buildSignatureLine(
                'Manager Signature',
              ),
            ),
            pw.SizedBox(width: 16),
            pw.Expanded(
              child: ReportPdfTableHelpers.buildSignatureLine('Date'),
            ),
          ],
        ),
      ],
    ),
  );
}
