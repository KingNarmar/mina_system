import 'package:mina_system/features/audit_logs/data/models/audit_log_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/company_invitation_model.dart';
import '../models/company_member_model.dart';
import '../models/invite_company_user_request.dart';

class CompanyUsersRepo {
  CompanyUsersRepo({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<List<CompanyMemberModel>> getCompanyMembers({
    required String companyId,
  }) async {
    final data = await _supabase.rpc(
      'get_company_members_for_team',
      params: {'p_company_id': companyId},
    );

    if (data is! List) {
      return const <CompanyMemberModel>[];
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(CompanyMemberModel.fromJson)
        .toList(growable: false);
  }

  Future<List<CompanyInvitationModel>> getCompanyInvitations({
    required String companyId,
  }) async {
    final data = await _supabase
        .from('company_invitations')
        .select(_companyInvitationSelect)
        .eq('company_id', companyId)
        .order('created_at', ascending: false);

    return data.map((item) {
      return CompanyInvitationModel.fromJson(item);
    }).toList();
  }

  Future<List<AuditLogModel>> getCompanyUserLifecycleAuditLogs({
    required String companyId,
    int limit = 50,
  }) async {
    final cleanCompanyId = companyId.trim();

    if (cleanCompanyId.isEmpty) {
      throw StateError('Company ID was not found.');
    }

    final safeLimit = _normalizeAuditLogLimit(limit);

    final data = await _supabase
        .from('audit_logs')
        .select(_auditLogSelectColumns)
        .eq('company_id', cleanCompanyId)
        .inFilter('action', _companyUserLifecycleAuditActions)
        .order('created_at', ascending: false)
        .limit(safeLimit);

    return data.map((item) {
      return AuditLogModel.fromJson(item);
    }).toList();
  }

  Future<List<CompanyInvitationModel>>
  getCurrentUserPendingInvitations() async {
    final currentUserEmail = _supabase.auth.currentUser?.email
        ?.trim()
        .toLowerCase();

    if (currentUserEmail == null || currentUserEmail.isEmpty) {
      throw Exception('Current user email was not found.');
    }

    final data = await _supabase
        .from('company_invitations')
        .select(_companyInvitationSelect)
        .eq('email', currentUserEmail)
        .eq('status', 'pending')
        .gt('expires_at', DateTime.now().toUtc().toIso8601String())
        .order('created_at', ascending: false);

    return data.map((item) {
      return CompanyInvitationModel.fromJson(item);
    }).toList();
  }

  Future<void> inviteCompanyUser({
    required InviteCompanyUserRequest request,
  }) async {
    await _supabase.rpc(
      'invite_company_user',
      params: {
        'p_company_id': request.companyId,
        'p_email': request.email,
        'p_role': request.role,
      },
    );
  }

  Future<void> changeCompanyMemberRole({
    required String companyId,
    required String memberId,
    required String newRole,
  }) async {
    await _supabase.rpc(
      'change_company_member_role',
      params: {
        'p_company_id': companyId,
        'p_member_id': memberId,
        'p_new_role': newRole,
      },
    );
  }

  Future<void> deactivateCompanyMember({
    required String companyId,
    required String memberId,
  }) async {
    await _supabase.rpc(
      'deactivate_company_member',
      params: {'p_company_id': companyId, 'p_member_id': memberId},
    );
  }

  Future<void> reactivateCompanyMember({
    required String companyId,
    required String memberId,
  }) async {
    await _supabase.rpc(
      'reactivate_company_member',
      params: {'p_company_id': companyId, 'p_member_id': memberId},
    );
  }

  Future<String> acceptCompanyInvitation({required String invitationId}) async {
    final companyId = await _supabase.rpc(
      'accept_company_invitation',
      params: {'p_invitation_id': invitationId},
    );

    return companyId as String;
  }

  Future<String> cancelCompanyInvitation({required String invitationId}) async {
    final companyId = await _supabase.rpc(
      'cancel_company_invitation',
      params: {'p_invitation_id': invitationId},
    );

    return companyId as String;
  }

  int _normalizeAuditLogLimit(int limit) {
    if (limit <= 0) {
      return 50;
    }

    if (limit > 100) {
      return 100;
    }

    return limit;
  }

  static const List<String> _companyUserLifecycleAuditActions = [
    'company_user_invited',
    'company_invitation_accepted',
    'company_invitation_cancelled',
    'company_member_role_changed',
    'company_member_deactivated',
    'company_member_reactivated',
  ];

  static const String _auditLogSelectColumns = '''
    id,
    company_id,
    actor_profile_id,
    actor_name_snapshot,
    actor_email_snapshot,
    action,
    entity_type,
    entity_id,
    entity_label_snapshot,
    old_data,
    new_data,
    metadata,
    created_at
  ''';

  static const String _companyInvitationSelect = '''
    id,
    company_id,
    email,
    role,
    status,
    invited_by_profile_id,
    accepted_by_profile_id,
    cancelled_by_profile_id,
    expires_at,
    created_at,
    accepted_at,
    cancelled_at,
    updated_at,
   company:companies!company_invitations_company_id_fkey(
  name,
  timezone
),
    invited_by_profile:profiles!company_invitations_invited_by_profile_id_fkey(
      full_name,
      email
    ),
    accepted_by_profile:profiles!company_invitations_accepted_by_profile_id_fkey(
      full_name,
      email
    ),
    cancelled_by_profile:profiles!company_invitations_cancelled_by_profile_id_fkey(
      full_name,
      email
    )
  ''';
}
