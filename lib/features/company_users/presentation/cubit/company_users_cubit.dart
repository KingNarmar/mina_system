import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/services/network_status_service.dart';
import 'package:mina_system/core/utils/app_error_message.dart';
import 'package:mina_system/features/audit_logs/data/models/audit_log_model.dart';

import '../../data/models/invite_company_user_request.dart';
import '../../data/repo/company_users_repo.dart';
import 'company_users_state.dart';

part 'company_users_cubit_invitations.dart';
part 'company_users_cubit_members.dart';

class CompanyUsersCubit extends Cubit<CompanyUsersState> {
  CompanyUsersCubit({
    CompanyUsersRepo? repo,
    NetworkStatusService? networkStatusService,
  }) : _repo = repo ?? CompanyUsersRepo(),
       _networkStatusService = networkStatusService ?? NetworkStatusService(),
       super(const CompanyUsersState());

  final CompanyUsersRepo _repo;
  final NetworkStatusService _networkStatusService;

  Future<void> loadCompanyUsers({
    required String companyId,
    bool showLoader = true,
    String? completedActionKey,
  }) async {
    if (showLoader) {
      emit(
        state.copyWith(
          isLoading: true,
          clearCompletedActionKey: true,
          clearErrorMessage: true,
        ),
      );
    } else {
      emit(state.copyWith(clearErrorMessage: true));
    }

    try {
      final members = await _repo.getCompanyMembers(companyId: companyId);
      final companyInvitations = await _repo.getCompanyInvitations(
        companyId: companyId,
      );
      final companyUserLifecycleAuditLogs =
          await _loadCompanyUserLifecycleAuditLogs(companyId: companyId);

      emit(
        state.copyWith(
          members: members,
          companyInvitations: companyInvitations,
          companyUserLifecycleAuditLogs: companyUserLifecycleAuditLogs,
          isLoading: false,
          isSubmitting: false,
          clearSubmittingActionKey: true,
          completedActionKey: completedActionKey,
          clearCompletedActionKey: completedActionKey == null,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          isSubmitting: false,
          clearSubmittingActionKey: true,
          clearCompletedActionKey: true,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to load company users. Please try again.',
          ),
        ),
      );
    }
  }

  Future<List<AuditLogModel>> _loadCompanyUserLifecycleAuditLogs({
    required String companyId,
  }) async {
    try {
      return await _repo.getCompanyUserLifecycleAuditLogs(companyId: companyId);
    } catch (_) {
      return const <AuditLogModel>[];
    }
  }

  void clearErrorMessage() {
    if (state.errorMessage == null) {
      return;
    }

    emit(state.copyWith(clearErrorMessage: true));
  }

  void emitState(CompanyUsersState state) => emit(state);

  Future<bool> _ensureOnline() async {
    try {
      await _networkStatusService.ensureOnline();
      return true;
    } on NetworkUnavailableException catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          clearSubmittingActionKey: true,
          clearCompletedActionKey: true,
          errorMessage: error.message,
        ),
      );
      return false;
    }
  }
}
