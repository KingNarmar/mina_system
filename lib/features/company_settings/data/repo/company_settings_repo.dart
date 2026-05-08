import 'dart:typed_data';

import 'package:mina_system/core/services/image_compression_service.dart';
import 'package:mina_system/core/services/network_status_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/company_document_template_model.dart';
import '../models/company_profile_model.dart';
import '../models/company_report_settings_model.dart';

class CompanySettingsRepo {
  CompanySettingsRepo({
    SupabaseClient? supabaseClient,
    ImageCompressionService imageCompressionService =
        const ImageCompressionService(),
    NetworkStatusService? networkStatusService,
  }) : _supabase = supabaseClient ?? Supabase.instance.client,
       _imageCompressionService = imageCompressionService,
       _networkStatusService = networkStatusService ?? NetworkStatusService();

  final SupabaseClient _supabase;
  final ImageCompressionService _imageCompressionService;
  final NetworkStatusService _networkStatusService;

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

  Future<CompanyReportSettingsModel> getCompanyReportSettings({
    required String companyId,
  }) async {
    final data = await _supabase
        .from('company_report_settings')
        .select()
        .eq('company_id', companyId)
        .single();

    return CompanyReportSettingsModel.fromJson(data);
  }

  Future<List<CompanyDocumentTemplateModel>> getCompanyDocumentTemplates({
    required String companyId,
  }) async {
    final data = await _supabase
        .from('company_document_templates')
        .select()
        .eq('company_id', companyId)
        .order('report_type');

    return data.map<CompanyDocumentTemplateModel>((item) {
      return CompanyDocumentTemplateModel.fromJson(item);
    }).toList();
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

  Future<CompanyReportSettingsModel> updateCompanyReportSettings({
    required CompanyReportSettingsModel reportSettings,
  }) async {
    final data = await _supabase
        .from('company_report_settings')
        .update(reportSettings.toUpdateJson())
        .eq('id', reportSettings.id)
        .select()
        .single();

    return CompanyReportSettingsModel.fromJson(data);
  }

  Future<CompanyDocumentTemplateModel> updateCompanyDocumentTemplate({
    required CompanyDocumentTemplateModel documentTemplate,
  }) async {
    final data = await _supabase
        .from('company_document_templates')
        .update(documentTemplate.toUpdateJson())
        .eq('id', documentTemplate.id)
        .select()
        .single();

    return CompanyDocumentTemplateModel.fromJson(data);
  }

  Future<CompanyProfileModel> uploadCompanyLogo({
    required String companyId,
    required Uint8List bytes,
    required String fileExtension,
    required String contentType,
  }) async {
    await _networkStatusService.ensureOnline();

    final currentCompanyData = await _supabase
        .from('companies')
        .select('logo_path')
        .eq('id', companyId)
        .single();

    final oldLogoPath = currentCompanyData['logo_path'] as String?;

    final compressedLogo = await _imageCompressionService.compressImageBytes(
      sourceBytes: bytes,
      fileExtension: fileExtension,
      quality: ImageCompressionService.companyLogoQuality,
      maxDimension: ImageCompressionService.companyLogoMaxDimension,
      sourceDescription: 'company logo',
    );

    final filePath =
        '$companyId/logo/company-logo-${DateTime.now().millisecondsSinceEpoch}.${compressedLogo.extension}';

    await _supabase.storage
        .from('company-assets')
        .uploadBinary(
          filePath,
          compressedLogo.bytes,
          fileOptions: FileOptions(
            contentType: compressedLogo.contentType,
            upsert: false,
          ),
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
