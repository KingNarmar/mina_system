import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/utils/app_error_message.dart';
import 'package:mina_system/features/audit_logs/data/models/audit_log_model.dart';
import 'package:mina_system/features/audit_logs/data/repo/audit_logs_repo.dart';
import 'package:mina_system/features/audit_logs/data/services/audit_log_lookup_resolver.dart';
import 'package:mina_system/features/audit_logs/presentation/cubit/audit_logs_state.dart';

class AuditLogsCubit extends Cubit<AuditLogsState> {
  AuditLogsCubit({AuditLogsRepo? auditLogsRepo})
    : _auditLogsRepo = auditLogsRepo ?? AuditLogsRepo(),
      super(const AuditLogsState(auditLogs: _initialAuditLogs));

  final AuditLogsRepo _auditLogsRepo;

  static const List<AuditLogModel> _initialAuditLogs = [];

  Future<void> loadAuditLogsByEntity({
    required String companyId,
    required String entityType,
    required String entityId,
    int limit = 100,
  }) async {
    final cleanCompanyId = companyId.trim();
    final cleanEntityType = entityType.trim();
    final cleanEntityId = entityId.trim();

    emit(
      state.copyWith(
        companyId: cleanCompanyId,
        entityType: cleanEntityType,
        entityId: cleanEntityId,
        isLoading: true,
        clearErrorMessage: true,
      ),
    );

    try {
      final auditLogs = await _auditLogsRepo.getAuditLogsByEntity(
        companyId: cleanCompanyId,
        entityType: cleanEntityType,
        entityId: cleanEntityId,
        limit: limit,
      );

      final lookupResolver = await AuditLogLookupResolver.load(
        companyId: cleanCompanyId,
      );

      emit(
        state.copyWith(
          auditLogs: auditLogs,
          lookupResolver: lookupResolver,
          companyId: cleanCompanyId,
          entityType: cleanEntityType,
          entityId: cleanEntityId,
          isLoading: false,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to load audit history. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> loadRecentAuditLogs({
    required String companyId,
    int limit = 50,
  }) async {
    final cleanCompanyId = companyId.trim();

    emit(
      AuditLogsState(
        auditLogs: const [],
        companyId: cleanCompanyId,
        isLoading: true,
      ),
    );

    try {
      final auditLogs = await _auditLogsRepo.getRecentAuditLogs(
        companyId: cleanCompanyId,
        limit: limit,
      );

      final lookupResolver = await AuditLogLookupResolver.load(
        companyId: cleanCompanyId,
      );

      emit(
        AuditLogsState(
          auditLogs: auditLogs,
          lookupResolver: lookupResolver,
          companyId: cleanCompanyId,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to load recent audit logs. Please try again.',
          ),
        ),
      );
    }
  }

  void clearAuditLogs() {
    emit(const AuditLogsState(auditLogs: _initialAuditLogs));
  }

  void clearErrorMessage() {
    if (state.errorMessage == null) {
      return;
    }

    emit(state.copyWith(clearErrorMessage: true));
  }
}
