import 'package:mina_system/features/reports/data/models/report_option_model.dart';

class ReportFilterVisibility {
  static bool shouldShowWorkerFilter(ReportType type) {
    switch (type) {
      case ReportType.workerCustody:
      case ReportType.transactions:
      case ReportType.lostDamaged:
      case ReportType.lostDamagedApproval:
        return true;
      case ReportType.toolHistory:
      case ReportType.toolSummary:
        return false;
    }
  }

  static bool shouldShowToolFilter(ReportType type) {
    switch (type) {
      case ReportType.toolHistory:
      case ReportType.transactions:
      case ReportType.lostDamaged:
      case ReportType.lostDamagedApproval:
      case ReportType.toolSummary:
        return true;
      case ReportType.workerCustody:
        return false;
    }
  }

  static bool shouldShowTypeFilter(ReportType type) {
    return type == ReportType.transactions;
  }

  static bool shouldShowApprovalStatusFilter(ReportType type) {
    return type == ReportType.transactions ||
        type == ReportType.lostDamaged ||
        type == ReportType.lostDamagedApproval;
  }
}
