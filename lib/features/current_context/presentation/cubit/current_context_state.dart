import '../../data/models/company_model.dart';
import '../../data/models/profile_model.dart';

abstract class CurrentContextState {
  const CurrentContextState();
}

class CurrentContextInitial extends CurrentContextState {
  const CurrentContextInitial();
}

class CurrentContextLoading extends CurrentContextState {
  const CurrentContextLoading();
}

class CurrentContextLoaded extends CurrentContextState {
  const CurrentContextLoaded({
    required this.profile,
    required this.companies,
    required this.currentCompany,
  });

  final ProfileModel profile;
  final List<CompanyModel> companies;
  final CompanyModel? currentCompany;

  bool get hasNoCompany => companies.isEmpty;

  bool get hasOneCompany => companies.length == 1;

  bool get hasMultipleCompanies => companies.length > 1;
}

class CurrentContextFailure extends CurrentContextState {
  const CurrentContextFailure(this.message);

  final String message;
}
