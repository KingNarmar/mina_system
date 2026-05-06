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

  static pw.Widget _buildWorkerCustodyTable(
      List<TransactionModel> transactions) {
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

  static pw.Widget _buildTransactionsTable(
      List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return _buildEmptyMessage('No matching transactions found.');
    }

    return pw.TableHelper.fromTextArray(
      headers: const ['Code', 'Type', 'Worker', 'Tool', 'Qty', 'Unit', 'Date'],
      data: transactions.map((transaction) {
        return [
          transaction.transactionCode,
          ReportPdfFormatters.getTransactionTypeLabel(transaction.type),
          transaction.workerName,
          transaction.toolName,
          transaction.quantity.toStringAsFixed(2),
          transaction.unit,
          ReportPdfFormatters.formatDate(transaction.dateTime),
        ];
      }).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(6),
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
}
