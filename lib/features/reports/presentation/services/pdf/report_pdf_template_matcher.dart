import 'package:mina_system/features/company_settings/data/models/company_document_template_model.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';
import 'report_pdf_formatters.dart';

class ReportPdfTemplateMatcher {
  static CompanyDocumentTemplateModel? findDocumentTemplate({
    required ReportType reportType,
    required List<CompanyDocumentTemplateModel> documentTemplates,
  }) {
    final expectedType = ReportPdfFormatters.normalizeTemplateText(
      ReportPdfFormatters.getTemplateReportType(reportType),
    );
    final expectedTitle = ReportPdfFormatters.normalizeTemplateText(
      ReportPdfFormatters.getReportTitle(reportType),
    );

    for (final template in documentTemplates) {
      if (!template.isActive) {
        continue;
      }

      final templateType = ReportPdfFormatters.normalizeTemplateText(
        template.reportType,
      );
      final templateTitle = ReportPdfFormatters.normalizeTemplateText(
        template.documentTitle,
      );

      final matchesType =
          templateType == expectedType ||
          templateType == expectedTitle ||
          templateType.contains(expectedType) ||
          expectedType.contains(templateType);

      final matchesTitle =
          templateTitle == expectedTitle ||
          templateTitle.contains(expectedType) ||
          expectedTitle.contains(templateTitle);

      if (matchesType || matchesTitle) {
        return template;
      }
    }

    return null;
  }
}
