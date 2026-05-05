import 'dart:typed_data';

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

  Future<CompanyProfileModel> uploadCompanyLogo({
    required String companyId,
    required Uint8List bytes,
    required String fileExtension,
    required String contentType,
  }) async {
    final currentCompanyData = await _supabase
        .from('companies')
        .select('logo_path')
        .eq('id', companyId)
        .single();

    final oldLogoPath = currentCompanyData['logo_path'] as String?;

    final cleanExtension = fileExtension.replaceAll('.', '').toLowerCase();

    final filePath =
        '$companyId/logo/company-logo-${DateTime.now().millisecondsSinceEpoch}.$cleanExtension';

    await _supabase.storage
        .from('company-assets')
        .uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: false),
        );

    final updatedCompanyData = await _supabase
        .from('companies')
        .update({'logo_path': filePath})
        .eq('id', companyId)
        .select()
        .single();

    if (oldLogoPath != null &&
        oldLogoPath.trim().isNotEmpty &&
        oldLogoPath != filePath) {
      await _supabase.storage.from('company-assets').remove([oldLogoPath]);
    }

    return CompanyProfileModel.fromJson(updatedCompanyData);
  }
}
