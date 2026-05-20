import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/company_model.dart';
import '../models/create_company_request.dart';
import '../models/profile_model.dart';

class CurrentContextRepo {
  CurrentContextRepo({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  static const int _sessionRefreshBufferInSeconds = 60;

  Future<ProfileModel> getCurrentProfile() async {
    return _withFreshSessionRetry(() async {
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
    });
  }

  Future<List<CompanyModel>> getCurrentUserCompanies({
    required String profileId,
  }) async {
    return _withFreshSessionRetry(() async {
      final memberships = await _supabase
          .from('company_members')
          .select('company_id, role')
          .eq('profile_id', profileId)
          .eq('status', 'active');

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
    });
  }

  Future<String?> getActiveCompanyMembershipRole({
    required String profileId,
    required String companyId,
  }) async {
    return _withFreshSessionRetry(() async {
      final cleanProfileId = profileId.trim();
      final cleanCompanyId = companyId.trim();

      if (cleanProfileId.isEmpty || cleanCompanyId.isEmpty) {
        return null;
      }

      final data = await _supabase
          .from('company_members')
          .select('role')
          .eq('profile_id', cleanProfileId)
          .eq('company_id', cleanCompanyId)
          .eq('status', 'active')
          .maybeSingle();

      if (data == null) {
        return null;
      }

      return data['role'] as String?;
    });
  }

  Future<bool> hasActiveCompanyMembership({
    required String profileId,
    required String companyId,
  }) async {
    final role = await getActiveCompanyMembershipRole(
      profileId: profileId,
      companyId: companyId,
    );

    return role != null;
  }

  Future<String> createCompany(CreateCompanyRequest request) async {
    return _withFreshSessionRetry(() async {
      final companyId = await _supabase.rpc(
        'create_company_with_defaults',
        params: request.toJson(),
      );

      return companyId as String;
    });
  }

  Future<T> _withFreshSessionRetry<T>(Future<T> Function() action) async {
    await _ensureFreshSession();

    try {
      return await action();
    } catch (error) {
      if (!_isExpiredJwtError(error)) {
        rethrow;
      }

      _debugSession('Expired JWT detected. Forcing session refresh.');

      await _ensureFreshSession(forceRefresh: true);

      _debugSession('Session refreshed. Retrying request once.');

      return action();
    }
  }

  Future<void> _ensureFreshSession({bool forceRefresh = false}) async {
    final session = _supabase.auth.currentSession;

    if (session == null) {
      throw Exception('No authenticated session found.');
    }

    if (!forceRefresh && !_shouldRefreshSession(session)) {
      return;
    }

    _debugSession(
      forceRefresh
          ? 'Force refreshing auth session.'
          : 'Refreshing auth session before expiry.',
    );

    final response = await _supabase.auth.refreshSession();
    final refreshedSession = response.session ?? _supabase.auth.currentSession;

    if (refreshedSession == null || _supabase.auth.currentUser == null) {
      throw Exception('Session expired. Please log in again.');
    }

    _debugSession('Auth session refresh completed.');
  }

  bool _shouldRefreshSession(Session session) {
    final expiresAt = session.expiresAt;

    if (expiresAt == null) {
      return false;
    }

    final nowInSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final refreshBefore = nowInSeconds + _sessionRefreshBufferInSeconds;

    return expiresAt <= refreshBefore;
  }

  bool _isExpiredJwtError(Object error) {
    final errorText = error.toString().toLowerCase();

    return errorText.contains('jwt expired') ||
        errorText.contains('pgrst303') ||
        errorText.contains('unauthorized');
  }

  void _debugSession(String message) {
    if (!kDebugMode) {
      return;
    }

    debugPrint('[MinaAuthSession] $message');
  }
}
