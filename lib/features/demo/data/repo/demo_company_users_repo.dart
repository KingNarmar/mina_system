import 'package:mina_system/features/audit_logs/data/models/audit_log_model.dart';
import 'package:mina_system/features/company_users/data/models/company_invitation_model.dart';
import 'package:mina_system/features/company_users/data/models/company_member_model.dart';
import 'package:mina_system/features/company_users/data/models/invite_company_user_request.dart';
import 'package:mina_system/features/company_users/data/repo/company_users_repo.dart';
import 'package:mina_system/features/demo/data/demo_limits.dart';
import 'package:mina_system/features/demo/data/services/demo_local_storage_service.dart';
import 'package:mina_system/features/demo/data/services/demo_seed_service.dart';
import 'package:mina_system/features/demo/data/services/demo_storage_keys.dart';

class DemoCompanyUsersRepo extends CompanyUsersRepo {
  DemoCompanyUsersRepo({
    DemoLocalStorageService storage = const DemoLocalStorageService(),
  }) : _storage = storage;

  final DemoLocalStorageService _storage;

  @override
  Future<List<CompanyMemberModel>> getCompanyMembers({
    required String companyId,
  }) async {
    await _ensureTeamSeeded(companyId: companyId);

    final membersData = await _storage.readJsonList(
      DemoStorageKeys.companyMembers,
    );

    final members = membersData
        .where((item) => item['company_id'] == companyId)
        .map(CompanyMemberModel.fromJson)
        .toList();

    members.sort((first, second) {
      return (first.createdAt ?? DateTime(1970)).compareTo(
        second.createdAt ?? DateTime(1970),
      );
    });

    return members;
  }

  @override
  Future<List<CompanyInvitationModel>> getCompanyInvitations({
    required String companyId,
  }) async {
    await _ensureTeamSeeded(companyId: companyId);

    final invitationsData = await _storage.readJsonList(
      DemoStorageKeys.companyInvitations,
    );

    final invitations = invitationsData
        .where((item) => item['company_id'] == companyId)
        .map(CompanyInvitationModel.fromJson)
        .toList();

    invitations.sort((first, second) {
      return second.createdAt.compareTo(first.createdAt);
    });

    return invitations;
  }

  @override
  Future<List<AuditLogModel>> getCompanyUserLifecycleAuditLogs({
    required String companyId,
    int limit = 50,
  }) async {
    await _ensureTeamSeeded(companyId: companyId);

    final auditLogsData = await _storage.readJsonList(
      DemoStorageKeys.companyUserAuditLogs,
    );

    final auditLogs = auditLogsData
        .where((item) => item['company_id'] == companyId)
        .map(AuditLogModel.fromJson)
        .toList();

    auditLogs.sort((first, second) {
      return (second.createdAt ?? DateTime(1970)).compareTo(
        first.createdAt ?? DateTime(1970),
      );
    });

    return auditLogs.take(limit).toList(growable: false);
  }

  @override
  Future<List<CompanyInvitationModel>>
  getCurrentUserPendingInvitations() async {
    return const [];
  }

  @override
  Future<void> inviteCompanyUser({
    required InviteCompanyUserRequest request,
  }) async {
    await _ensureTeamSeeded(companyId: request.companyId);

    final now = DateTime.now();
    final invitationId = 'demo-invitation-${now.microsecondsSinceEpoch}';
    final cleanEmail = request.email.trim().toLowerCase();

    if (cleanEmail.isEmpty) {
      throw StateError('Email address was not found.');
    }

    final invitationsData = await _storage.readJsonList(
      DemoStorageKeys.companyInvitations,
    );

    _ensureCanInviteCompanyUser(
      invitationsData: invitationsData,
      companyId: request.companyId,
    );

    final invitationJson = _invitationJson(
      id: invitationId,
      companyId: request.companyId,
      email: cleanEmail,
      role: request.role,
      status: 'pending',
      createdAt: now,
      updatedAt: now,
      expiresAt: now.add(const Duration(days: 7)),
    );

    await _storage.writeJsonList(
      key: DemoStorageKeys.companyInvitations,
      value: [invitationJson, ...invitationsData],
    );

    await _appendAuditLog(
      companyId: request.companyId,
      action: 'company_user_invited',
      entityType: 'company_invitation',
      entityId: invitationId,
      entityLabel: cleanEmail,
      newData: {'email': cleanEmail, 'role': request.role, 'status': 'pending'},
    );
  }

  @override
  Future<void> changeCompanyMemberRole({
    required String companyId,
    required String memberId,
    required String newRole,
  }) async {
    await _ensureTeamSeeded(companyId: companyId);

    final membersData = await _storage.readJsonList(
      DemoStorageKeys.companyMembers,
    );

    Map<String, dynamic>? oldMemberJson;
    Map<String, dynamic>? updatedMemberJson;

    final now = DateTime.now();

    final updatedMembers = membersData
        .map((item) {
          if (item['id'] != memberId || item['company_id'] != companyId) {
            return item;
          }

          oldMemberJson = Map<String, dynamic>.from(item);

          updatedMemberJson = {
            ...item,
            'role': newRole,
            'updated_at': now.toIso8601String(),
          };

          return updatedMemberJson!;
        })
        .toList(growable: false);

    if (updatedMemberJson == null) {
      throw StateError('Demo company member was not found.');
    }

    await _storage.writeJsonList(
      key: DemoStorageKeys.companyMembers,
      value: updatedMembers,
    );

    await _appendAuditLog(
      companyId: companyId,
      action: 'company_member_role_changed',
      entityType: 'company_user',
      entityId: memberId,
      entityLabel: _resolveMemberDisplayName(updatedMemberJson!),
      oldData: {'role': oldMemberJson?['role']},
      newData: {'role': newRole},
    );
  }

  @override
  Future<void> deactivateCompanyMember({
    required String companyId,
    required String memberId,
  }) async {
    await _updateMemberStatus(
      companyId: companyId,
      memberId: memberId,
      status: 'inactive',
      action: 'company_member_deactivated',
    );
  }

  @override
  Future<void> reactivateCompanyMember({
    required String companyId,
    required String memberId,
  }) async {
    await _updateMemberStatus(
      companyId: companyId,
      memberId: memberId,
      status: 'active',
      action: 'company_member_reactivated',
    );
  }

  @override
  Future<String> acceptCompanyInvitation({required String invitationId}) async {
    return DemoSeedService.demoCompanyId;
  }

  @override
  Future<String> cancelCompanyInvitation({required String invitationId}) async {
    final invitationsData = await _storage.readJsonList(
      DemoStorageKeys.companyInvitations,
    );

    final now = DateTime.now();

    Map<String, dynamic>? updatedInvitationJson;

    final updatedInvitations = invitationsData
        .map((item) {
          if (item['id'] != invitationId) {
            return item;
          }

          updatedInvitationJson = {
            ...item,
            'status': 'cancelled',
            'cancelled_by_profile_id': DemoSeedService.demoProfileId,
            'cancelled_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          };

          return updatedInvitationJson!;
        })
        .toList(growable: false);

    if (updatedInvitationJson == null) {
      throw StateError('Demo invitation was not found.');
    }

    await _storage.writeJsonList(
      key: DemoStorageKeys.companyInvitations,
      value: updatedInvitations,
    );

    final companyId = updatedInvitationJson!['company_id'] as String;

    await _appendAuditLog(
      companyId: companyId,
      action: 'company_invitation_cancelled',
      entityType: 'company_invitation',
      entityId: invitationId,
      entityLabel: updatedInvitationJson!['email'] as String?,
      oldData: {'status': 'pending'},
      newData: {'status': 'cancelled'},
    );

    return companyId;
  }

  Future<void> _updateMemberStatus({
    required String companyId,
    required String memberId,
    required String status,
    required String action,
  }) async {
    await _ensureTeamSeeded(companyId: companyId);

    final membersData = await _storage.readJsonList(
      DemoStorageKeys.companyMembers,
    );

    final now = DateTime.now();

    Map<String, dynamic>? oldMemberJson;
    Map<String, dynamic>? updatedMemberJson;

    final updatedMembers = membersData
        .map((item) {
          if (item['id'] != memberId || item['company_id'] != companyId) {
            return item;
          }

          oldMemberJson = Map<String, dynamic>.from(item);

          updatedMemberJson = {
            ...item,
            'status': status,
            'updated_at': now.toIso8601String(),
          };

          return updatedMemberJson!;
        })
        .toList(growable: false);

    if (updatedMemberJson == null) {
      throw StateError('Demo company member was not found.');
    }

    await _storage.writeJsonList(
      key: DemoStorageKeys.companyMembers,
      value: updatedMembers,
    );

    await _appendAuditLog(
      companyId: companyId,
      action: action,
      entityType: 'company_user',
      entityId: memberId,
      entityLabel: _resolveMemberDisplayName(updatedMemberJson!),
      oldData: {'status': oldMemberJson?['status']},
      newData: {'status': status},
    );
  }

  void _ensureCanInviteCompanyUser({
    required List<Map<String, dynamic>> invitationsData,
    required String companyId,
  }) {
    final pendingInvitationsCount = invitationsData.where((item) {
      final itemCompanyId = item['company_id'] as String?;
      final itemStatus = item['status'] as String?;

      return itemCompanyId == companyId &&
          itemStatus?.trim().toLowerCase() == 'pending';
    }).length;

    if (pendingInvitationsCount >= DemoLimits.maxPendingInvitations) {
      throw StateError(DemoLimits.invitationsLimitMessage());
    }
  }

  Future<void> _ensureTeamSeeded({required String companyId}) async {
    final membersData = await _storage.readJsonList(
      DemoStorageKeys.companyMembers,
    );

    if (membersData.any((item) => item['company_id'] == companyId)) {
      return;
    }

    final now = DateTime.now();

    await _storage.writeJsonList(
      key: DemoStorageKeys.companyMembers,
      value: _buildDemoMembers(companyId: companyId, now: now),
    );

    await _storage.writeJsonList(
      key: DemoStorageKeys.companyInvitations,
      value: _buildDemoInvitations(companyId: companyId, now: now),
    );

    await _storage.writeJsonList(
      key: DemoStorageKeys.companyUserAuditLogs,
      value: _buildDemoAuditLogs(companyId: companyId, now: now),
    );
  }

  List<Map<String, dynamic>> _buildDemoMembers({
    required String companyId,
    required DateTime now,
  }) {
    return [
      _memberJson(
        id: 'demo-member-owner',
        companyId: companyId,
        profileId: DemoSeedService.demoProfileId,
        role: 'owner',
        status: 'active',
        fullName: 'Demo User',
        email: 'demo@mina-system.local',
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now.subtract(const Duration(days: 45)),
      ),
      _memberJson(
        id: 'demo-member-warehouse-manager',
        companyId: companyId,
        profileId: 'demo-profile-warehouse-manager',
        role: 'warehouse_manager',
        status: 'active',
        fullName: 'Mina Demo Manager',
        email: 'warehouse.manager@demo.local',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 30)),
      ),
      _memberJson(
        id: 'demo-member-admin',
        companyId: companyId,
        profileId: 'demo-profile-admin',
        role: 'admin',
        status: 'active',
        fullName: 'Admin Demo User',
        email: 'admin@demo.local',
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now.subtract(const Duration(days: 25)),
      ),
      _memberJson(
        id: 'demo-member-inactive',
        companyId: companyId,
        profileId: 'demo-profile-inactive',
        role: 'warehouse_user',
        status: 'inactive',
        fullName: 'Inactive Demo User',
        email: 'inactive.user@demo.local',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  List<Map<String, dynamic>> _buildDemoInvitations({
    required String companyId,
    required DateTime now,
  }) {
    return [
      _invitationJson(
        id: 'demo-invitation-pending-001',
        companyId: companyId,
        email: 'new.storekeeper@demo.local',
        role: 'warehouse_user',
        status: 'pending',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        expiresAt: now.add(const Duration(days: 6)),
      ),
    ];
  }

  List<Map<String, dynamic>> _buildDemoAuditLogs({
    required String companyId,
    required DateTime now,
  }) {
    return [
      _auditLogJson(
        id: 'demo-team-audit-001',
        companyId: companyId,
        action: 'company_user_invited',
        entityType: 'company_invitation',
        entityId: 'demo-invitation-pending-001',
        entityLabel: 'new.storekeeper@demo.local',
        createdAt: now.subtract(const Duration(days: 1)),
        newData: {
          'email': 'new.storekeeper@demo.local',
          'role': 'warehouse_user',
          'status': 'pending',
        },
      ),
      _auditLogJson(
        id: 'demo-team-audit-002',
        companyId: companyId,
        action: 'company_member_deactivated',
        entityType: 'company_user',
        entityId: 'demo-member-inactive',
        entityLabel: 'Inactive Demo User',
        createdAt: now.subtract(const Duration(days: 5)),
        oldData: {'status': 'active'},
        newData: {'status': 'inactive'},
      ),
    ];
  }

  Map<String, dynamic> _memberJson({
    required String id,
    required String companyId,
    required String profileId,
    required String role,
    required String status,
    required String fullName,
    required String email,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return {
      'id': id,
      'company_id': companyId,
      'profile_id': profileId,
      'role': role,
      'status': status,
      'joined_at': createdAt.toIso8601String(),
      'invited_by_profile_id': DemoSeedService.demoProfileId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'member_profile': {'full_name': fullName, 'email': email},
      'invited_by_profile': {
        'full_name': 'Demo User',
        'email': 'demo@mina-system.local',
      },
    };
  }

  Map<String, dynamic> _invitationJson({
    required String id,
    required String companyId,
    required String email,
    required String role,
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime expiresAt,
  }) {
    return {
      'id': id,
      'company_id': companyId,
      'email': email,
      'role': role,
      'status': status,
      'invited_by_profile_id': DemoSeedService.demoProfileId,
      'accepted_by_profile_id': null,
      'cancelled_by_profile_id': null,
      'expires_at': expiresAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'accepted_at': null,
      'cancelled_at': null,
      'updated_at': updatedAt.toIso8601String(),
      'company': {'name': 'Demo Marine Services LLC', 'timezone': 'Asia/Dubai'},
      'invited_by_profile': {
        'full_name': 'Demo User',
        'email': 'demo@mina-system.local',
      },
      'accepted_by_profile': null,
      'cancelled_by_profile': null,
    };
  }

  Map<String, dynamic> _auditLogJson({
    required String id,
    required String companyId,
    required String action,
    required String entityType,
    required String entityId,
    required String? entityLabel,
    required DateTime createdAt,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
    Map<String, dynamic>? metadata,
  }) {
    return {
      'id': id,
      'company_id': companyId,
      'actor_profile_id': DemoSeedService.demoProfileId,
      'actor_name_snapshot': 'Demo User',
      'actor_email_snapshot': 'demo@mina-system.local',
      'action': action,
      'entity_type': entityType,
      'entity_id': entityId,
      'entity_label_snapshot': entityLabel,
      'old_data': oldData,
      'new_data': newData,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Future<void> _appendAuditLog({
    required String companyId,
    required String action,
    required String entityType,
    required String entityId,
    required String? entityLabel,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
    Map<String, dynamic>? metadata,
  }) async {
    final auditLogsData = await _storage.readJsonList(
      DemoStorageKeys.companyUserAuditLogs,
    );

    final now = DateTime.now();

    final auditLogJson = _auditLogJson(
      id: 'demo-team-audit-${now.microsecondsSinceEpoch}',
      companyId: companyId,
      action: action,
      entityType: entityType,
      entityId: entityId,
      entityLabel: entityLabel,
      createdAt: now,
      oldData: oldData,
      newData: newData,
      metadata: metadata,
    );

    await _storage.writeJsonList(
      key: DemoStorageKeys.companyUserAuditLogs,
      value: [auditLogJson, ...auditLogsData],
    );
  }

  String _resolveMemberDisplayName(Map<String, dynamic> memberJson) {
    final profileJson = memberJson['member_profile'];

    if (profileJson is Map<String, dynamic>) {
      final fullName = profileJson['full_name'] as String?;

      if (fullName != null && fullName.trim().isNotEmpty) {
        return fullName.trim();
      }

      final email = profileJson['email'] as String?;

      if (email != null && email.trim().isNotEmpty) {
        return email.trim();
      }
    }

    return memberJson['id']?.toString() ?? 'Demo Member';
  }
}
