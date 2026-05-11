import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/services/network_status_service.dart';
import 'package:mina_system/core/utils/app_error_message.dart';

import '../../data/models/invite_company_user_request.dart';
import '../../data/repo/company_users_repo.dart';
import 'company_users_state.dart';

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
  }) async {
    if (showLoader) {
      emit(state.copyWith(isLoading: true, clearErrorMessage: true));
    } else {
      emit(state.copyWith(clearErrorMessage: true));
    }

    try {
      final members = await _repo.getCompanyMembers(companyId: companyId);
      final companyInvitations = await _repo.getCompanyInvitations(
        companyId: companyId,
      );

      emit(
        state.copyWith(
          members: members,
          companyInvitations: companyInvitations,
          isLoading: false,
          isSubmitting: false,
          clearSubmittingActionKey: true,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          isSubmitting: false,
          clearSubmittingActionKey: true,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to load company users. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> inviteCompanyUser({
    required String companyId,
    required String email,
    required String role,
  }) async {
    final canContinue = await _ensureOnline();

    if (!canContinue) {
      return;
    }

    emit(
      state.copyWith(
        isSubmitting: true,
        submittingActionKey: CompanyUsersSubmissionKey.invite,
        clearErrorMessage: true,
      ),
    );

    try {
      await _repo.inviteCompanyUser(
        request: InviteCompanyUserRequest(
          companyId: companyId,
          email: email,
          role: role,
        ),
      );

      await loadCompanyUsers(companyId: companyId, showLoader: false);
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          clearSubmittingActionKey: true,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to invite user. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> changeCompanyMemberRole({
    required String companyId,
    required String memberId,
    required String newRole,
  }) async {
    final canContinue = await _ensureOnline();

    if (!canContinue) {
      return;
    }

    emit(
      state.copyWith(
        isSubmitting: true,
        submittingActionKey: CompanyUsersSubmissionKey.changeRole(memberId),
        clearErrorMessage: true,
      ),
    );

    try {
      await _repo.changeCompanyMemberRole(
        companyId: companyId,
        memberId: memberId,
        newRole: newRole,
      );

      await loadCompanyUsers(companyId: companyId, showLoader: false);
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          clearSubmittingActionKey: true,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to change member role. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> deactivateCompanyMember({
    required String companyId,
    required String memberId,
  }) async {
    final canContinue = await _ensureOnline();

    if (!canContinue) {
      return;
    }

    emit(
      state.copyWith(
        isSubmitting: true,
        submittingActionKey: CompanyUsersSubmissionKey.deactivateMember(
          memberId,
        ),
        clearErrorMessage: true,
      ),
    );

    try {
      await _repo.deactivateCompanyMember(
        companyId: companyId,
        memberId: memberId,
      );

      await loadCompanyUsers(companyId: companyId, showLoader: false);
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          clearSubmittingActionKey: true,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to deactivate member. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> reactivateCompanyMember({
    required String companyId,
    required String memberId,
  }) async {
    final canContinue = await _ensureOnline();

    if (!canContinue) {
      return;
    }

    emit(
      state.copyWith(
        isSubmitting: true,
        submittingActionKey: CompanyUsersSubmissionKey.reactivateMember(
          memberId,
        ),
        clearErrorMessage: true,
      ),
    );

    try {
      await _repo.reactivateCompanyMember(
        companyId: companyId,
        memberId: memberId,
      );

      await loadCompanyUsers(companyId: companyId, showLoader: false);
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          clearSubmittingActionKey: true,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to reactivate member. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> loadCurrentUserPendingInvitations() async {
    emit(
      state.copyWith(
        isCurrentUserInvitationsLoading: true,
        clearErrorMessage: true,
      ),
    );

    try {
      final currentUserInvitations = await _repo
          .getCurrentUserPendingInvitations();

      emit(
        state.copyWith(
          currentUserInvitations: currentUserInvitations,
          isCurrentUserInvitationsLoading: false,
          hasLoadedCurrentUserInvitations: true,
          isSubmitting: false,
          clearSubmittingActionKey: true,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isCurrentUserInvitationsLoading: false,
          hasLoadedCurrentUserInvitations: true,
          isSubmitting: false,
          clearSubmittingActionKey: true,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to load pending invitations. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> acceptInvitation({required String invitationId}) async {
    final canContinue = await _ensureOnline();

    if (!canContinue) {
      return;
    }

    emit(
      state.copyWith(
        isSubmitting: true,
        submittingActionKey: CompanyUsersSubmissionKey.acceptInvitation(
          invitationId,
        ),
        clearErrorMessage: true,
      ),
    );

    try {
      await _repo.acceptCompanyInvitation(invitationId: invitationId);

      final currentUserInvitations = await _repo
          .getCurrentUserPendingInvitations();

      emit(
        state.copyWith(
          currentUserInvitations: currentUserInvitations,
          isSubmitting: false,
          clearSubmittingActionKey: true,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          clearSubmittingActionKey: true,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to accept invitation. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> cancelInvitation({
    required String companyId,
    required String invitationId,
  }) async {
    final canContinue = await _ensureOnline();

    if (!canContinue) {
      return;
    }

    emit(
      state.copyWith(
        isSubmitting: true,
        submittingActionKey: CompanyUsersSubmissionKey.cancelInvitation(
          invitationId,
        ),
        clearErrorMessage: true,
      ),
    );

    try {
      await _repo.cancelCompanyInvitation(invitationId: invitationId);

      await loadCompanyUsers(companyId: companyId, showLoader: false);
    } catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          clearSubmittingActionKey: true,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to cancel invitation. Please try again.',
          ),
        ),
      );
    }
  }

  void clearErrorMessage() {
    if (state.errorMessage == null) {
      return;
    }

    emit(state.copyWith(clearErrorMessage: true));
  }

  Future<bool> _ensureOnline() async {
    try {
      await _networkStatusService.ensureOnline();
      return true;
    } on NetworkUnavailableException catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          clearSubmittingActionKey: true,
          errorMessage: error.message,
        ),
      );
      return false;
    }
  }
}
