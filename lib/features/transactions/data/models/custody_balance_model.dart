class CustodyBalanceModel {
  const CustodyBalanceModel({
    required this.workerHrCode,
    required this.workerName,
    required this.toolCode,
    required this.toolName,
    required this.unit,
    required this.balanceQuantity,
  });

  final String workerHrCode;
  final String workerName;
  final String toolCode;
  final String toolName;
  final String unit;
  final double balanceQuantity;
}