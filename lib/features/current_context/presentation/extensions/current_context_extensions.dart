import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/company_model.dart';
import '../cubit/current_context_cubit.dart';
import '../cubit/current_context_state.dart';

extension CurrentContextExtensions on BuildContext {
  CurrentContextLoaded? get currentContext {
    final state = read<CurrentContextCubit>().state;

    if (state is CurrentContextLoaded) {
      return state;
    }

    return null;
  }

  String? get currentProfileId {
    return currentContext?.profile.id;
  }

  CompanyModel? get currentCompany {
    return currentContext?.currentCompany;
  }

  String? get currentCompanyId {
    return currentCompany?.id;
  }

  String? get currentUserRole {
    return currentCompany?.role;
  }

  String requireCurrentProfileId() {
    final profileId = currentProfileId;

    if (profileId == null) {
      throw StateError('Current profile is not loaded.');
    }

    return profileId;
  }

  String requireCurrentCompanyId() {
    final companyId = currentCompanyId;

    if (companyId == null) {
      throw StateError('Current company is not selected.');
    }

    return companyId;
  }

  String requireCurrentUserRole() {
    final role = currentUserRole;

    if (role == null) {
      throw StateError('Current user role is not loaded.');
    }

    return role;
  }
}