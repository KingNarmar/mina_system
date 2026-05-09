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
    final data = await _supabase
        .from('company_members')
        .select('''
          id,
          company_id,
          profile_id,
          role,
          status,
          joined_at,
          invited_by_profile_id,
          created_at,
          updated_at,
          member_profile:profiles!company_members_profile_id_fkey(
            full_name,
            email
          )
        ''')
        .eq('company_id', companyId)
        .order('created_at');

    return data.map((item) {
      return CompanyMemberModel.fromJson(item);
    }).toList();
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

  Future<List<CompanyInvitationModel>>
  getCurrentUserPendingInvitations() async {
    final data = await _supabase
        .from('company_invitations')
        .select(_companyInvitationSelect)
        .eq('status', 'pending')
        .gt('expires_at', DateTime.now().toUtc().toIso8601String())
        .order('created_at', ascending: false);

    return data.map((item) {
      return CompanyInvitationModel.fromJson(item);
    }).toList();
  }

  Future<CompanyInvitationModel> inviteCompanyUser({
    required InviteCompanyUserRequest request,
  }) async {
    final data = await _supabase
        .from('company_invitations')
        .insert(request.toJson())
        .select(_companyInvitationSelect)
        .single();

    return CompanyInvitationModel.fromJson(data);
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
      name
    ),
    invited_by_profile:profiles!company_invitations_invited_by_profile_id_fkey(
      full_name,
      email
    )
  ''';
}
