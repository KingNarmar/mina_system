import 'package:shared_preferences/shared_preferences.dart';

class CurrentCompanyStorageService {
  const CurrentCompanyStorageService();

  static const String _lastSelectedCompanyIdPrefix =
      'last_selected_company_id_';

  Future<void> saveLastSelectedCompanyId({
    required String profileId,
    required String companyId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_buildLastSelectedCompanyIdKey(profileId), companyId);
  }

  Future<String?> getLastSelectedCompanyId({required String profileId}) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_buildLastSelectedCompanyIdKey(profileId));
  }

  Future<void> clearLastSelectedCompanyId({required String profileId}) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_buildLastSelectedCompanyIdKey(profileId));
  }

  String _buildLastSelectedCompanyIdKey(String profileId) {
    return '$_lastSelectedCompanyIdPrefix$profileId';
  }
}
