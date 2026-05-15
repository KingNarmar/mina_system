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

  static const String _companyProfileSelectColumns = '''
    id,
    name,
    trade_name,
    legal_name,
    trade_license_no,
    tax_registration_no,
    address_line_1,
    address_line_2,
    city,
    country,
    phone,
    email,
    website,
    logo_path,
    timezone,
    created_by_profile_id,
    updated_by_profile_id,
    created_at,
    updated_at,
    created_by_profile:profiles!companies_created_by_profile_id_fkey(
      full_name,
      email
    ),
    updated_by_profile:profiles!companies_updated_by_profile_id_fkey(
      full_name,
      email
    )
  ''';

  static const String _companyReportSettingsSelectColumns = '''
    id,
    company_id,
    default_timezone,
    date_format,
    time_format,
    show_company_logo,
    show_company_details,
    show_document_control,
    show_generated_by,
    report_footer_text,
    custody_responsibility_statement,
    loss_damage_responsibility_statement,
    created_by_profile_id,
    updated_by_profile_id,
    created_at,
    updated_at,
    created_by_profile:profiles!company_report_settings_created_by_profile_id_fkey(
      full_name,
      email
    ),
    updated_by_profile:profiles!company_report_settings_updated_by_profile_id_fkey(
      full_name,
      email
    )
  ''';

  static const String _companyDocumentTemplateSelectColumns = '''
    id,
    company_id,
    report_type,
    document_title,
    document_code,
    issue_no,
    revision_no,
    effective_date,
    prepared_by_title,
    checked_by_title,
    approved_by_title,
    worker_signature_label,
    manager_signature_label,
    storekeeper_signature_label,
    is_active,
    created_by_profile_id,
    updated_by_profile_id,
    created_at,
    updated_at,
    created_by_profile:profiles!company_document_templates_created_by_profile_id_fkey(
      full_name,
      email
    ),
    updated_by_profile:profiles!company_document_templates_updated_by_profile_id_fkey(
      full_name,
      email
    )
  ''';

  Future<CompanyProfileModel> getCompanyProfile({
    required String companyId,
  }) async {
    final data = await _supabase
        .from('companies')
        .select(_companyProfileSelectColumns)
        .eq('id', companyId)
        .single();

    return CompanyProfileModel.fromJson(data);
  }

  Future<CompanyReportSettingsModel> getCompanyReportSettings({
    required String companyId,
  }) async {
    final data = await _supabase
        .from('company_report_settings')
        .select(_companyReportSettingsSelectColumns)
        .eq('company_id', companyId)
        .single();

    return CompanyReportSettingsModel.fromJson(data);
  }

  Future<List<CompanyDocumentTemplateModel>> getCompanyDocumentTemplates({
    required String companyId,
  }) async {
    final data = await _supabase
        .from('company_document_templates')
        .select(_companyDocumentTemplateSelectColumns)
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
        .select(_companyProfileSelectColumns)
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
        .select(_companyReportSettingsSelectColumns)
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
        .select(_companyDocumentTemplateSelectColumns)
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
        .select(_companyProfileSelectColumns)
        .single();

    if (oldLogoPath != null &&
        oldLogoPath.trim().isNotEmpty &&
        oldLogoPath != filePath) {
      await _supabase.storage.from('company-assets').remove([oldLogoPath]);
    }

    return CompanyProfileModel.fromJson(updatedCompanyData);
  }
}
