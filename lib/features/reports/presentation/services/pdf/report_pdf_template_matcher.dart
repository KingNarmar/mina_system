import 'package:mina_system/features/company_settings/data/models/company_document_template_model.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';

class ReportPdfTemplateMatcher {
  static CompanyDocumentTemplateModel? findDocumentTemplate({
    required ReportType reportType,
    required List<CompanyDocumentTemplateModel> documentTemplates,
  }) {
    final expectedTemplateReportType = _getExpectedTemplateReportType(
      reportType,
    );

    for (final template in documentTemplates) {
      if (!template.isActive) {
        continue;
      }

      if (template.reportType == expectedTemplateReportType) {
        return template;
      }
    }

    return null;
  }

  static String _getExpectedTemplateReportType(ReportType reportType) {
    switch (reportType) {
      case ReportType.workerCustody:
        return 'worker_custody_report';
      case ReportType.toolHistory:
        return 'tool_history_report';
      case ReportType.transactions:
        return 'transactions_report';
      case ReportType.lostDamaged:
        return 'lost_damaged_report';
      case ReportType.lostDamagedApproval:
        return 'loss_damage_report';
      case ReportType.toolSummary:
        return 'tool_summary_report';
    }
  }
}
