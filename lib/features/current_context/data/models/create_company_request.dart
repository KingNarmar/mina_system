class CreateCompanyRequest {
  const CreateCompanyRequest({
    required this.companyName,
    this.tradeName,
    this.legalName,
  });

  final String companyName;
  final String? tradeName;
  final String? legalName;

  Map<String, dynamic> toJson() {
    return {
      'p_name': companyName.trim(),
      'p_trade_name': tradeName?.trim(),
      'p_legal_name': legalName?.trim(),
    };
  }
}