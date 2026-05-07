import 'package:mina_system/features/reports/data/models/report_filter_model.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';

List<TransactionModel> applyReportTransactionFilters({
  required List<TransactionModel> transactions,
  required ReportFilterModel filters,
  bool lostDamagedOnly = false,
}) {
  return transactions.where((transaction) {
    if (lostDamagedOnly && !transaction.isLost && !transaction.isDamaged) {
      return false;
    }

    if (filters.worker != null &&
        _normalizeText(transaction.workerHrCode) !=
            _normalizeText(filters.worker!.hrCode)) {
      return false;
    }

    if (filters.tool != null &&
        _normalizeText(transaction.toolCode) !=
            _normalizeText(filters.tool!.toolCode)) {
      return false;
    }

    if (filters.transactionType != null &&
        transaction.type != filters.transactionType) {
      return false;
    }

    if (filters.approvalStatus != null &&
        _normalizeText(transaction.approvalStatus) !=
            _normalizeText(filters.approvalStatus!)) {
      return false;
    }

    if (filters.dateFrom != null &&
        transaction.dateTime.isBefore(_startOfDay(filters.dateFrom!))) {
      return false;
    }

    if (filters.dateTo != null &&
        transaction.dateTime.isAfter(_endOfDay(filters.dateTo!))) {
      return false;
    }

    return true;
  }).toList();
}

DateTime _startOfDay(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

DateTime _endOfDay(DateTime date) {
  return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
}

String _normalizeText(String value) {
  return value.trim().toLowerCase();
}
