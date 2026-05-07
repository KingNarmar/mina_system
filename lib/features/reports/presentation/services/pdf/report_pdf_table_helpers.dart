import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportPdfTableHelpers {
  static pw.Widget buildSectionTitle(String title) {
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

  static pw.Widget buildTwoColumnDetails(List<PdfDetailItem> items) {
    final rows = <pw.TableRow>[];

    for (var index = 0; index < items.length; index += 2) {
      final first = items[index];
      final second = index + 1 < items.length ? items[index + 1] : null;

      rows.add(
        pw.TableRow(
          children: [buildDetailCell(first), buildDetailCell(second)],
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: const {0: pw.FlexColumnWidth(1), 1: pw.FlexColumnWidth(1)},
      children: rows,
    );
  }

  static pw.Widget buildDetailCell(PdfDetailItem? item) {
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
            cleanPdfValue(item.value),
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

  static pw.Widget buildTextBox(String text, {double minHeight = 38}) {
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

  static pw.Widget buildSignatureLine(String label) {
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

  static pw.Widget buildCheckBox({
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

  static bool hasPdfText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  static String cleanPdfValue(String? value) {
    final cleanValue = value?.trim();

    if (cleanValue == null || cleanValue.isEmpty) {
      return '-';
    }

    return cleanValue;
  }

  static String formatPdfQuantity(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  static String limitPdfText(String value, {required int maxLength}) {
    if (value.length <= maxLength) {
      return value;
    }

    return '${value.substring(0, maxLength)}...';
  }
}

class PdfDetailItem {
  const PdfDetailItem({required this.label, required this.value});

  final String label;
  final String? value;
}
