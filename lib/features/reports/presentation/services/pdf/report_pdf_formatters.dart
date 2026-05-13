import 'package:mina_system/core/utils/company_date_time_formatter.dart';
import 'package:mina_system/features/reports/data/models/report_option_model.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';

class ReportPdfFormatters {
  static String getReportTitle(ReportType reportType) {
    switch (reportType) {
      case ReportType.workerCustody:
        return 'Worker Custody Report';
      case ReportType.toolHistory:
        return 'Tool History Report';
      case ReportType.transactions:
        return 'Transactions Report';
      case ReportType.lostDamaged:
        return 'Lost & Damaged Report';
      case ReportType.lostDamagedApproval:
        return 'Lost/Damaged Approval Report';
      case ReportType.toolSummary:
        return 'Tool Summary Report';
    }
  }

  static String getTemplateReportType(ReportType reportType) {
    switch (reportType) {
      case ReportType.workerCustody:
        return 'worker_custody';
      case ReportType.toolHistory:
        return 'tool_history';
      case ReportType.transactions:
        return 'transactions';
      case ReportType.lostDamaged:
        return 'lost_damaged';
      case ReportType.lostDamagedApproval:
        return 'lost_damaged_approval';
      case ReportType.toolSummary:
        return 'tool_summary';
    }
  }

  static String getTransactionTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.issue:
        return 'Issue';
      case TransactionType.returnTool:
        return 'Return';
      case TransactionType.lost:
        return 'Lost';
      case TransactionType.damaged:
        return 'Damaged';
    }
  }

  static String getApprovalStatusLabel(TransactionModel transaction) {
    if (!transaction.approvalRequired) {
      return 'N/A';
    }

    return getApprovalStatusValueLabel(transaction.approvalStatus);
  }

  static String getApprovalStatusValueLabel(String? approvalStatus) {
    final status = approvalStatus?.trim().toLowerCase();

    switch (status) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'not_required':
      case null:
      case '':
        return 'N/A';
      default:
        return formatTemplateReportType(status);
    }
  }

  static String getSettlementStatusValueLabel(String? settlementStatus) {
    final status = settlementStatus?.trim().toLowerCase();

    switch (status) {
      case 'pending_settlement':
        return 'Pending Settlement';
      case 'settled':
        return 'Settled';
      case 'not_required':
      case null:
      case '':
        return 'N/A';
      default:
        return formatTemplateReportType(status);
    }
  }

  static String formatTemplateReportType(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.trim().isNotEmpty)
        .map((word) {
          final lowerWord = word.toLowerCase();
          return '${lowerWord[0].toUpperCase()}${lowerWord.substring(1)}';
        })
        .join(' ');
  }

  static String formatDate(
    DateTime date, {
    String? timezone,
    String? dateFormat,
  }) {
    return CompanyDateTimeFormatter.formatDate(
      date,
      timezone: timezone,
      dateFormat: dateFormat,
    );
  }

  static String normalizeTemplateText(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  static String getSignatureLabel({
    required String? label,
    required String fallback,
  }) {
    final trimmedLabel = label?.trim();

    if (trimmedLabel == null || trimmedLabel.isEmpty) {
      return fallback;
    }

    return trimmedLabel;
  }
}
