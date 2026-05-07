import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/company_settings/data/models/company_document_template_model.dart';
import 'package:mina_system/features/company_settings/data/models/company_profile_model.dart';
import 'package:mina_system/features/company_settings/data/models/company_report_settings_model.dart';
import 'package:mina_system/features/reports/data/models/report_filter_model.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';
import 'package:mina_system/features/reports/presentation/services/report_pdf_service.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:printing/printing.dart';

void showReportPdfPreview(
  BuildContext context, {
  required ReportType reportType,
  required ReportFilterModel filters,
  required List<TransactionModel> transactions,
  required CompanyProfileModel companyProfile,
  required CompanyReportSettingsModel reportSettings,
  required List<CompanyDocumentTemplateModel> documentTemplates,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final height = MediaQuery.sizeOf(context).height;
  final isMobile = width < AppBreakpoints.tablet;

  final preview = _ReportPdfPreview(
    reportType: reportType,
    filters: filters,
    transactions: transactions,
    companyProfile: companyProfile,
    reportSettings: reportSettings,
    documentTemplates: documentTemplates,
  );

  if (isMobile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.background,
      builder: (_) {
        return SizedBox(height: height * 0.92, child: preview);
      },
    );
    return;
  }

  showDialog(
    context: context,
    builder: (_) {
      return Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1100, maxHeight: height * 0.9),
          child: preview,
        ),
      );
    },
  );
}

class _ReportPdfPreview extends StatelessWidget {
  const _ReportPdfPreview({
    required this.reportType,
    required this.filters,
    required this.transactions,
    required this.companyProfile,
    required this.reportSettings,
    required this.documentTemplates,
  });

  final ReportType reportType;
  final ReportFilterModel filters;
  final List<TransactionModel> transactions;
  final CompanyProfileModel companyProfile;
  final CompanyReportSettingsModel reportSettings;
  final List<CompanyDocumentTemplateModel> documentTemplates;

  @override
  Widget build(BuildContext context) {
    final pdfService = ReportPdfService();

    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _getReportTitle(reportType),
                    style: AppTextStyles.title,
                  ),
                ),
                const Gap(12),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: PdfPreview(
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              allowPrinting: true,
              allowSharing: true,
              pdfFileName: _buildPdfFileName(reportType),
              build: (_) {
                return pdfService.buildReportPdf(
                  reportType: reportType,
                  filters: filters,
                  transactions: transactions,
                  companyProfile: companyProfile,
                  reportSettings: reportSettings,
                  documentTemplates: documentTemplates,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getReportTitle(ReportType reportType) {
    switch (reportType) {
      case ReportType.workerCustody:
        return 'Worker Custody Report';
      case ReportType.toolHistory:
        return 'Tool History Report';
      case ReportType.transactions:
        return 'Transactions Report';
      case ReportType.lostDamaged:
        return 'Lost & Damaged Report';
      case ReportType.toolSummary:
        return 'Tool Summary Report';
    }
  }

  String _buildPdfFileName(ReportType reportType) {
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    switch (reportType) {
      case ReportType.workerCustody:
        return 'worker-custody-report-$date.pdf';
      case ReportType.toolHistory:
        return 'tool-history-report-$date.pdf';
      case ReportType.transactions:
        return 'transactions-report-$date.pdf';
      case ReportType.lostDamaged:
        return 'lost-damaged-report-$date.pdf';
      case ReportType.toolSummary:
        return 'tool-summary-report-$date.pdf';
    }
  }
}
