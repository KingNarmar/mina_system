class CompanyModel {
  const CompanyModel({required this.id, required this.name, this.role});

  final String id;
  final String name;
  final String? role;

  factory CompanyModel.fromJson({
    required Map<String, dynamic> companyJson,
    String? role,
  }) {
    return CompanyModel(
      id: companyJson['id'] as String,
      name: companyJson['name'] as String,
      role: role,
    );
  }

  CompanyModel copyWith({String? id, String? name, String? role}) {
    return CompanyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
    );
  }
}
