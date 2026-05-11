import 'package:mina_system/core/theme/app_pdf_text_styles.dart';
import 'package:mina_system/core/theme/app_pdf_colors.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/transactions/presentation/functions/custody_balance_calculator.dart';

import 'package:pdf/widgets.dart' as pw;
import 'report_pdf_empty_message.dart';

pw.Widget buildWorkerCustodyPdfTableSection(
  List<TransactionModel> transactions,
) {
  final balances = calculateCustodyBalances(transactions);

  if (balances.isEmpty) {
    return buildReportPdfEmptyMessage('No open custody balances found.');
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
    headerStyle: AppPdfTextStyles.sectionTitle,
    headerDecoration: const pw.BoxDecoration(color: AppPdfColors.grey300),
    cellStyle: const pw.TextStyle(fontSize: 9),
    cellAlignment: pw.Alignment.centerLeft,
    cellPadding: const pw.EdgeInsets.all(6),
  );
}
