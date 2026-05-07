import 'package:mina_system/features/company_settings/data/models/company_report_settings_model.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'report_pdf_empty_message.dart';
import 'report_pdf_formatters.dart';

pw.Widget buildTransactionsPdfTableSection({
  required List<TransactionModel> transactions,
  required CompanyReportSettingsModel reportSettings,
}) {
  if (transactions.isEmpty) {
    return buildReportPdfEmptyMessage('No matching transactions found.');
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
