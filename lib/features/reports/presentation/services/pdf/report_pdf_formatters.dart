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

  static String formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
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
