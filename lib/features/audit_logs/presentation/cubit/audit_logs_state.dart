import 'package:mina_system/features/audit_logs/data/models/audit_log_model.dart';
import 'package:mina_system/features/audit_logs/data/services/audit_log_lookup_resolver.dart';

class AuditLogsState {
  const AuditLogsState({
    required this.auditLogs,
    this.lookupResolver = AuditLogLookupResolver.empty,
    this.companyId,
    this.entityType,
    this.entityId,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<AuditLogModel> auditLogs;
  final AuditLogLookupResolver lookupResolver;
  final String? companyId;
  final String? entityType;
  final String? entityId;
  final bool isLoading;
  final String? errorMessage;

  bool get hasLogs => auditLogs.isNotEmpty;

  bool get isEntityHistory {
    return entityType != null &&
        entityType!.trim().isNotEmpty &&
        entityId != null &&
        entityId!.trim().isNotEmpty;
  }

  AuditLogsState copyWith({
    List<AuditLogModel>? auditLogs,
    AuditLogLookupResolver? lookupResolver,
    String? companyId,
    String? entityType,
    String? entityId,
    bool? isLoading,
    String? errorMessage,
    bool clearEntityContext = false,
    bool clearErrorMessage = false,
  }) {
    return AuditLogsState(
      auditLogs: auditLogs ?? this.auditLogs,
      lookupResolver: lookupResolver ?? this.lookupResolver,
      companyId: clearEntityContext ? null : companyId ?? this.companyId,
      entityType: clearEntityContext ? null : entityType ?? this.entityType,
      entityId: clearEntityContext ? null : entityId ?? this.entityId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
