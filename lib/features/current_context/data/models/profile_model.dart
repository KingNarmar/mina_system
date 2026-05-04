class ProfileModel {
  const ProfileModel({
    required this.id,
    this.fullName,
    this.email,
  });

  final String id;
  final String? fullName;
  final String? email;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
    );
  }
}