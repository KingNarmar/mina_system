import 'package:mina_system/core/theme/app_pdf_text_styles.dart';
import 'package:mina_system/core/theme/app_pdf_colors.dart';

import 'package:pdf/widgets.dart' as pw;

pw.Widget buildReportPdfEmptyMessage(String message) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(14),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: AppPdfColors.grey300),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Text(message, style: AppPdfTextStyles.headerTitle),
  );
}
