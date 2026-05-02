class ToolCustodySummaryModel {
  const ToolCustodySummaryModel({
    required this.toolCode,
    required this.toolName,
    required this.unit,
    required this.issuedQuantity,
    required this.returnedQuantity,
    required this.lostQuantity,
    required this.damagedQuantity,
    required this.openCustodyQuantity,
    required this.totalMovements,
  });

  final String toolCode;
  final String toolName;
  final String unit;
  final double issuedQuantity;
  final double returnedQuantity;
  final double lostQuantity;
  final double damagedQuantity;
  final double openCustodyQuantity;
  final int totalMovements;

  ToolCustodySummaryModel copyWith({
    String? toolCode,
    String? toolName,
    String? unit,
    double? issuedQuantity,
    double? returnedQuantity,
    double? lostQuantity,
    double? damagedQuantity,
    double? openCustodyQuantity,
    int? totalMovements,
  }) {
    return ToolCustodySummaryModel(
      toolCode: toolCode ?? this.toolCode,
      toolName: toolName ?? this.toolName,
      unit: unit ?? this.unit,
      issuedQuantity: issuedQuantity ?? this.issuedQuantity,
      returnedQuantity: returnedQuantity ?? this.returnedQuantity,
      lostQuantity: lostQuantity ?? this.lostQuantity,
      damagedQuantity: damagedQuantity ?? this.damagedQuantity,
      openCustodyQuantity:
          openCustodyQuantity ?? this.openCustodyQuantity,
      totalMovements: totalMovements ?? this.totalMovements,
    );
  }
}