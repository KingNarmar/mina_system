import 'package:pdf/widgets.dart' as pw;
import 'package:mina_system/core/theme/app_pdf_colors.dart';

abstract class AppPdfTextStyles {
  static const pw.TextStyle headerTitle = pw.TextStyle(
    fontSize: 11,
    color: AppPdfColors.blueGrey900,
  );

  static final pw.TextStyle sectionTitle = pw.TextStyle(
    fontSize: 10,
    color: AppPdfColors.blueGrey900,
    fontWeight: pw.FontWeight.bold,
  );

  static const pw.TextStyle body = pw.TextStyle(
    fontSize: 9,
    color: AppPdfColors.blueGrey900,
  );

  static const pw.TextStyle bodySecondary = pw.TextStyle(
    fontSize: 9,
    color: AppPdfColors.blueGrey700,
  );

  static const pw.TextStyle bodyTertiary = pw.TextStyle(
    fontSize: 9,
    color: AppPdfColors.blueGrey600,
  );

  static const pw.TextStyle caption = pw.TextStyle(
    fontSize: 8,
    color: AppPdfColors.blueGrey500,
  );

  static final pw.TextStyle tableHeader = pw.TextStyle(
    fontSize: 8.5,
    color: AppPdfColors.blueGrey800,
    fontWeight: pw.FontWeight.bold,
  );

  static const pw.TextStyle tableCell = pw.TextStyle(
    fontSize: 8,
    color: AppPdfColors.blueGrey800,
  );

  static const pw.TextStyle small = pw.TextStyle(
    fontSize: 7,
    color: AppPdfColors.blueGrey600,
  );
}
