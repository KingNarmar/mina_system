import 'package:mina_system/core/theme/app_pdf_text_styles.dart';
import 'package:mina_system/core/theme/app_pdf_colors.dart';
import 'package:mina_system/features/company_settings/data/models/company_report_settings_model.dart';

import 'package:pdf/widgets.dart' as pw;

class ReportPdfFooterSection {
  static pw.Widget buildFooter(CompanyReportSettingsModel reportSettings) {
    final footerText = reportSettings.reportFooterText?.trim();

    if (footerText == null || footerText.isEmpty) {
      return pw.SizedBox();
    }

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: AppPdfColors.grey300)),
      ),
      child: pw.Text(
        footerText,
        textAlign: pw.TextAlign.center,
        style: AppPdfTextStyles.bodyTertiary,
      ),
    );
  }

  static pw.Widget buildPageNumberFooter(pw.Context context) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: AppPdfColors.grey300)),
      ),
      child: pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: AppPdfTextStyles.caption,
        ),
      ),
    );
  }
}
