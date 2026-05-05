class ToolUnitModel {
  const ToolUnitModel({
    required this.id,
    required this.companyId,
    required this.name,
    this.symbol,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String companyId;
  final String name;
  final String? symbol;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ToolUnitModel.fromJson(Map<String, dynamic> json) {
    return ToolUnitModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'company_id': companyId,
      'name': name.trim(),
      'symbol': symbol?.trim(),
      'is_active': isActive,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name.trim(),
      'symbol': symbol?.trim(),
      'is_active': isActive,
    };
  }

  ToolUnitModel copyWith({
    String? id,
    String? companyId,
    String? name,
    String? symbol,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ToolUnitModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.parse(value as String);
  }
}
