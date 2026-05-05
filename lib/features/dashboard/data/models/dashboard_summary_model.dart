import 'package:mina_system/features/transactions/data/models/transaction_model.dart';

class DashboardSummaryModel {
  const DashboardSummaryModel({
    required this.totalWorkers,
    required this.totalTools,
    required this.openCustodies,
    required this.closedToday,
    required this.recentTransactions,
  });

  final int totalWorkers;
  final int totalTools;
  final int openCustodies;
  final int closedToday;
  final List<TransactionModel> recentTransactions;

  factory DashboardSummaryModel.empty() {
    return const DashboardSummaryModel(
      totalWorkers: 0,
      totalTools: 0,
      openCustodies: 0,
      closedToday: 0,
      recentTransactions: [],
    );
  }

  DashboardSummaryModel copyWith({
    int? totalWorkers,
    int? totalTools,
    int? openCustodies,
    int? closedToday,
    List<TransactionModel>? recentTransactions,
  }) {
    return DashboardSummaryModel(
      totalWorkers: totalWorkers ?? this.totalWorkers,
      totalTools: totalTools ?? this.totalTools,
      openCustodies: openCustodies ?? this.openCustodies,
      closedToday: closedToday ?? this.closedToday,
      recentTransactions: recentTransactions ?? this.recentTransactions,
    );
  }
}
