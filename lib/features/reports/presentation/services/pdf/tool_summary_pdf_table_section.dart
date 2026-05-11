import 'package:mina_system/core/theme/app_pdf_text_styles.dart';
import 'package:mina_system/core/theme/app_pdf_colors.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/tool_summary_calculator.dart';

import 'package:pdf/widgets.dart' as pw;
import 'report_pdf_empty_message.dart';

pw.Widget buildToolSummaryPdfTableSection(List<TransactionModel> transactions) {
  final summaries = calculateToolCustodySummaries(transactions);

  if (summaries.isEmpty) {
    return buildReportPdfEmptyMessage('No tool summary data found.');
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
    headerStyle: AppPdfTextStyles.sectionTitle,
    headerDecoration: const pw.BoxDecoration(color: AppPdfColors.grey300),
    cellStyle: const pw.TextStyle(fontSize: 9),
    cellAlignment: pw.Alignment.centerLeft,
    cellPadding: const pw.EdgeInsets.all(6),
  );
}
