class ToolModel {
  const ToolModel({
    required this.toolCode,
    required this.toolName,
    required this.unit,
    required this.category,
    required this.activeCustodyCount,
  });

  final String toolCode;
  final String toolName;
  final String unit;
  final String category;
  final int activeCustodyCount;

  ToolModel copyWith({
    String? toolCode,
    String? toolName,
    String? unit,
    String? category,
    int? activeCustodyCount,
  }) {
    return ToolModel(
      toolCode: toolCode ?? this.toolCode,
      toolName: toolName ?? this.toolName,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      activeCustodyCount: activeCustodyCount ?? this.activeCustodyCount,
    );
  }
}