import 'package:supabase_flutter/supabase_flutter.dart';

class CompanyRefreshArea {
  const CompanyRefreshArea._();

  static const String transactions = 'transactions';
  static const String workers = 'workers';
  static const String tools = 'tools';
  static const String companyUsers = 'company_users';
  static const String lookups = 'lookups';
}

class CompanyRefreshAreaResult {
  const CompanyRefreshAreaResult({
    required this.changeArea,
    required this.changedRows,
    required this.lastChangeAt,
  });

  final String changeArea;
  final int changedRows;
  final DateTime? lastChangeAt;

  factory CompanyRefreshAreaResult.fromJson(Map<String, dynamic> json) {
    return CompanyRefreshAreaResult(
      changeArea: (json['change_area'] as String? ?? '').trim(),
      changedRows: _parseInt(json['changed_rows']),
      lastChangeAt: _parseDateTime(json['last_change_at']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value.trim());
    }

    return null;
  }
}

class CompanyRefreshAreasService {
  CompanyRefreshAreasService({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<Set<String>> getChangedAreasSince({
    required String companyId,
    required DateTime since,
  }) async {
    final results = await getRefreshAreaResultsSince(
      companyId: companyId,
      since: since,
    );

    return results
        .map((result) => result.changeArea)
        .where((area) => area.isNotEmpty)
        .toSet();
  }

  Future<List<CompanyRefreshAreaResult>> getRefreshAreaResultsSince({
    required String companyId,
    required DateTime since,
  }) async {
    final cleanCompanyId = companyId.trim();

    if (cleanCompanyId.isEmpty) {
      return const [];
    }

    final response = await _supabase.rpc(
      'get_company_refresh_areas',
      params: {
        'p_company_id': cleanCompanyId,
        'p_since': since.toUtc().toIso8601String(),
      },
    );

    if (response is! List) {
      return const [];
    }

    return response
        .whereType<Map<String, dynamic>>()
        .map(CompanyRefreshAreaResult.fromJson)
        .where((result) => result.changeArea.isNotEmpty)
        .toList(growable: false);
  }
}
