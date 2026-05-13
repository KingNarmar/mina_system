import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/audit_log_model.dart';

class AuditLogsRepo {
  AuditLogsRepo({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

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

  Future<List<AuditLogModel>> getAuditLogsByEntity({
    required String companyId,
    required String entityType,
    required String entityId,
    int limit = 100,
  }) async {
    final cleanCompanyId = companyId.trim();
    final cleanEntityType = entityType.trim();
    final cleanEntityId = entityId.trim();

    if (cleanCompanyId.isEmpty) {
      throw StateError('Company ID was not found.');
    }

    if (cleanEntityType.isEmpty) {
      throw StateError('Entity type was not found.');
    }

    if (cleanEntityId.isEmpty) {
      throw StateError('Entity ID was not found.');
    }

    final safeLimit = _normalizeLimit(limit);

    final data = await _supabase
        .from('audit_logs')
        .select(_auditLogSelectColumns)
        .eq('company_id', cleanCompanyId)
        .eq('entity_type', cleanEntityType)
        .eq('entity_id', cleanEntityId)
        .order('created_at', ascending: false)
        .limit(safeLimit);

    return data.map((item) {
      return AuditLogModel.fromJson(item);
    }).toList();
  }

  Future<List<AuditLogModel>> getRecentAuditLogs({
    required String companyId,
    int limit = 50,
  }) async {
    final cleanCompanyId = companyId.trim();

    if (cleanCompanyId.isEmpty) {
      throw StateError('Company ID was not found.');
    }

    final safeLimit = _normalizeLimit(limit);

    final data = await _supabase
        .from('audit_logs')
        .select(_auditLogSelectColumns)
        .eq('company_id', cleanCompanyId)
        .order('created_at', ascending: false)
        .limit(safeLimit);

    return data.map((item) {
      return AuditLogModel.fromJson(item);
    }).toList();
  }

  int _normalizeLimit(int limit) {
    if (limit <= 0) {
      return 50;
    }

    if (limit > 200) {
      return 200;
    }

    return limit;
  }
}
