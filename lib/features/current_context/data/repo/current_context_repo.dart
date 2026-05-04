import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/company_model.dart';
import '../models/profile_model.dart';

class CurrentContextRepo {
  CurrentContextRepo({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<ProfileModel> getCurrentProfile() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    final data = await _supabase
        .from('profiles')
        .select()
        .eq('auth_user_id', user.id)
        .single();

    return ProfileModel.fromJson(data);
  }

  Future<List<CompanyModel>> getCurrentUserCompanies({
    required String profileId,
  }) async {
    final memberships = await _supabase
        .from('company_members')
        .select('company_id, role')
        .eq('profile_id', profileId);

    final companies = <CompanyModel>[];

    for (final membership in memberships) {
      final companyId = membership['company_id'] as String;
      final role = membership['role'] as String?;

      final companyData = await _supabase
          .from('companies')
          .select()
          .eq('id', companyId)
          .single();

      companies.add(
        CompanyModel.fromJson(companyJson: companyData, role: role),
      );
    }

    return companies;
  }
}
