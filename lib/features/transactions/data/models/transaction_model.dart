enum TransactionType { issue, returnTool, lost, damaged }

class TransactionModel {
  const TransactionModel({
    required this.transactionCode,
    required this.type,
    required this.workerHrCode,
    required this.workerName,
    required this.toolCode,
    required this.toolName,
    required this.unit,
    required this.quantity,
    required this.dateTime,
  });

  final String transactionCode;
  final TransactionType type;
  final String workerHrCode;
  final String workerName;
  final String toolCode;
  final String toolName;
  final String unit;
  final double quantity;
  final DateTime dateTime;

  bool get isIssue => type == TransactionType.issue;
  bool get isReturn => type == TransactionType.returnTool;
  bool get isLost => type == TransactionType.lost;
  bool get isDamaged => type == TransactionType.damaged;

  bool get isClosingTransaction => !isIssue;

  TransactionModel copyWith({
    String? transactionCode,
    TransactionType? type,
    String? workerHrCode,
    String? workerName,
    String? toolCode,
    String? toolName,
    String? unit,
    double? quantity,
    DateTime? dateTime,
  }) {
    return TransactionModel(
      transactionCode: transactionCode ?? this.transactionCode,
      type: type ?? this.type,
      workerHrCode: workerHrCode ?? this.workerHrCode,
      workerName: workerName ?? this.workerName,
      toolCode: toolCode ?? this.toolCode,
      toolName: toolName ?? this.toolName,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      dateTime: dateTime ?? this.dateTime,
    );
  }
}
