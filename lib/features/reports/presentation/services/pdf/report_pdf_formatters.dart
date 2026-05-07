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

  static String formatDate(DateTime date, {String? dateFormat}) {
    final normalizedFormat = _normalizeDateFormat(dateFormat);

    switch (normalizedFormat) {
      case 'dd/mm/yyyy':
        return '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}';

      case 'mm/dd/yyyy':
        return '${_twoDigits(date.month)}/${_twoDigits(date.day)}/${date.year}';

      case 'dd-mm-yyyy':
        return '${_twoDigits(date.day)}-${_twoDigits(date.month)}-${date.year}';

      case 'yyyy/mm/dd':
        return '${date.year}/${_twoDigits(date.month)}/${_twoDigits(date.day)}';

      case 'yyyy-mm-dd':
      default:
        return _formatYearMonthDay(date);
    }
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

  static String _normalizeDateFormat(String? dateFormat) {
    final cleanFormat = dateFormat
        ?.trim()
        .toLowerCase()
        .replaceAll('\\', '/')
        .replaceAll('.', '-')
        .replaceAll(' ', '');

    if (cleanFormat == null || cleanFormat.isEmpty) {
      return 'yyyy-mm-dd';
    }

    if (cleanFormat.contains('/')) {
      return _normalizeDateFormatBySeparator(cleanFormat, '/');
    }

    if (cleanFormat.contains('-')) {
      return _normalizeDateFormatBySeparator(cleanFormat, '-');
    }

    return 'yyyy-mm-dd';
  }

  static String _normalizeDateFormatBySeparator(
    String value,
    String separator,
  ) {
    final parts = value.split(separator);

    if (parts.length != 3) {
      return 'yyyy-mm-dd';
    }

    final normalizedParts = parts.map(_normalizeDateFormatPart).toList();

    if (normalizedParts.contains(null)) {
      return 'yyyy-mm-dd';
    }

    final normalizedFormat = normalizedParts.cast<String>().join(separator);

    switch (normalizedFormat) {
      case 'yyyy-mm-dd':
      case 'yyyy/mm/dd':
      case 'dd/mm/yyyy':
      case 'mm/dd/yyyy':
      case 'dd-mm-yyyy':
        return normalizedFormat;

      default:
        return 'yyyy-mm-dd';
    }
  }

  static String? _normalizeDateFormatPart(String value) {
    switch (value) {
      case 'yyyy':
      case 'yyy':
      case 'yy':
      case 'y':
        return 'yyyy';

      case 'mm':
      case 'm':
        return 'mm';

      case 'dd':
      case 'd':
        return 'dd';

      default:
        return null;
    }
  }

  static String _formatYearMonthDay(DateTime date) {
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
  }

  static String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}
