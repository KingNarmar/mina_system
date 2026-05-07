import 'package:mina_system/features/company_settings/data/models/company_report_settings_model.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:pdf/widgets.dart' as pw;

import 'lost_damaged_approval_pdf_section.dart';
import 'tool_summary_pdf_table_section.dart';
import 'transactions_pdf_table_section.dart';
import 'worker_custody_pdf_table_section.dart';

class ReportPdfTablesSection {
  static pw.Widget buildReportBody({
    required ReportType reportType,
    required List<TransactionModel> transactions,
    required CompanyReportSettingsModel reportSettings,
  }) {
    switch (reportType) {
      case ReportType.workerCustody:
        return buildWorkerCustodyPdfTableSection(transactions);

      case ReportType.toolSummary:
        return buildToolSummaryPdfTableSection(transactions);

      case ReportType.lostDamagedApproval:
        return buildLostDamagedApprovalPdfSection(
          transactions: transactions,
          reportSettings: reportSettings,
        );

      case ReportType.toolHistory:
      case ReportType.transactions:
      case ReportType.lostDamaged:
        return buildTransactionsPdfTableSection(
          transactions: transactions,
          reportSettings: reportSettings,
        );
    }
  }
}
