import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/company_profile_model.dart';

class CompanySettingsRepo {
  CompanySettingsRepo({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<CompanyProfileModel> getCompanyProfile({
    required String companyId,
  }) async {
    final data = await _supabase
        .from('companies')
        .select()
        .eq('id', companyId)
        .single();

    return CompanyProfileModel.fromJson(data);
  }

  Future<CompanyProfileModel> updateCompanyProfile({
    required CompanyProfileModel profile,
  }) async {
    final data = await _supabase
        .from('companies')
        .update(profile.toUpdateJson())
        .eq('id', profile.id)
        .select()
        .single();

    return CompanyProfileModel.fromJson(data);
  }
}