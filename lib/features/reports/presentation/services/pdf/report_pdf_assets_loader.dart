import 'dart:typed_data';

import 'package:mina_system/features/company_settings/data/models/company_profile_model.dart';
import 'package:mina_system/features/company_settings/data/models/company_report_settings_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportPdfAssetsLoader {
  static const String _companyAssetsBucket = 'company-assets';

  static Future<Uint8List?> loadCompanyLogoBytes({
    required SupabaseClient supabase,
    required CompanyProfileModel companyProfile,
    required CompanyReportSettingsModel reportSettings,
  }) async {
    if (!reportSettings.showCompanyLogo) {
      return null;
    }

    final logoPath = companyProfile.logoPath;

    if (logoPath == null || logoPath.trim().isEmpty) {
      return null;
    }

    try {
      return await supabase.storage
          .from(_companyAssetsBucket)
          .download(logoPath.trim());
    } catch (_) {
      return null;
    }
  }
}
