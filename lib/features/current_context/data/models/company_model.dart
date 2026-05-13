class CompanyModel {
  const CompanyModel({
    required this.id,
    required this.name,
    this.role,
    this.timezone = 'Asia/Dubai',
  });

  final String id;
  final String name;
  final String? role;
  final String timezone;

  factory CompanyModel.fromJson({
    required Map<String, dynamic> companyJson,
    String? role,
  }) {
    return CompanyModel(
      id: companyJson['id'] as String,
      name: companyJson['name'] as String,
      role: role,
      timezone: companyJson['timezone'] as String? ?? 'Asia/Dubai',
    );
  }

  CompanyModel copyWith({
    String? id,
    String? name,
    String? role,
    String? timezone,
  }) {
    return CompanyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      timezone: timezone ?? this.timezone,
    );
  }
}
