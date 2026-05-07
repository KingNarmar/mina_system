import 'package:mina_system/features/tools/data/models/tool_model.dart';
import 'package:mina_system/features/transactions/data/models/transaction_model.dart';
import 'package:mina_system/features/workers/data/models/worker_model.dart';

class ReportFilterModel {
  const ReportFilterModel({
    this.worker,
    this.tool,
    this.transactionType,
    this.approvalStatus,
    this.dateFrom,
    this.dateTo,
  });

  final WorkerModel? worker;
  final ToolModel? tool;
  final TransactionType? transactionType;
  final String? approvalStatus;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  ReportFilterModel copyWith({
    WorkerModel? worker,
    ToolModel? tool,
    TransactionType? transactionType,
    String? approvalStatus,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool clearWorker = false,
    bool clearTool = false,
    bool clearTransactionType = false,
    bool clearApprovalStatus = false,
    bool clearDateFrom = false,
    bool clearDateTo = false,
  }) {
    return ReportFilterModel(
      worker: clearWorker ? null : worker ?? this.worker,
      tool: clearTool ? null : tool ?? this.tool,
      transactionType: clearTransactionType
          ? null
          : transactionType ?? this.transactionType,
      approvalStatus: clearApprovalStatus
          ? null
          : approvalStatus ?? this.approvalStatus,
      dateFrom: clearDateFrom ? null : dateFrom ?? this.dateFrom,
      dateTo: clearDateTo ? null : dateTo ?? this.dateTo,
    );
  }

  bool get hasFilters {
    return worker != null ||
        tool != null ||
        transactionType != null ||
        approvalStatus != null ||
        dateFrom != null ||
        dateTo != null;
  }
}
