class ToolModel {
  const ToolModel({
    required this.toolCode,
    required this.toolName,
    required this.unit,
    required this.category,
  });

  final String toolCode;
  final String toolName;
  final String unit;
  final String category;

  ToolModel copyWith({
    String? toolCode,
    String? toolName,
    String? unit,
    String? category,
  }) {
    return ToolModel(
      toolCode: toolCode ?? this.toolCode,
      toolName: toolName ?? this.toolName,
      unit: unit ?? this.unit,
      category: category ?? this.category,
    );
  }
}
