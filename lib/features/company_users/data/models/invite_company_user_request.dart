class InviteCompanyUserRequest {
  const InviteCompanyUserRequest({
    required this.companyId,
    required this.email,
    required this.role,
  });

  final String companyId;
  final String email;
  final String role;

  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
      'email': email.trim().toLowerCase(),
      'role': role,
    };
  }
}
