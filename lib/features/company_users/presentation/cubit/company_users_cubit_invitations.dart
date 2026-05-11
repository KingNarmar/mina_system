part of 'company_users_cubit.dart';

extension CompanyUsersCubitInvitations on CompanyUsersCubit {
  Future<void> inviteCompanyUser({
    required String companyId,
    required String email,
    required String role,
  }) async {
    final canContinue = await _ensureOnline();

    if (!canContinue) {
      return;
    }

    emitState(
      state.copyWith(
        isSubmitting: true,
        submittingActionKey: CompanyUsersSubmissionKey.invite,
        clearCompletedActionKey: true,
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

      await loadCompanyUsers(
        companyId: companyId,
        showLoader: false,
        completedActionKey: CompanyUsersSubmissionKey.invite,
      );
    } catch (error) {
      emitState(
        state.copyWith(
          isSubmitting: false,
          clearSubmittingActionKey: true,
          clearCompletedActionKey: true,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to invite user. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> loadCurrentUserPendingInvitations() async {
    emitState(
      state.copyWith(
        isCurrentUserInvitationsLoading: true,
        clearCompletedActionKey: true,
        clearErrorMessage: true,
      ),
    );

    try {
      final currentUserInvitations = await _repo
          .getCurrentUserPendingInvitations();

      emitState(
        state.copyWith(
          currentUserInvitations: currentUserInvitations,
          isCurrentUserInvitationsLoading: false,
          hasLoadedCurrentUserInvitations: true,
          isSubmitting: false,
          clearSubmittingActionKey: true,
          clearCompletedActionKey: true,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emitState(
        state.copyWith(
          isCurrentUserInvitationsLoading: false,
          hasLoadedCurrentUserInvitations: true,
          isSubmitting: false,
          clearSubmittingActionKey: true,
          clearCompletedActionKey: true,
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

    final actionKey = CompanyUsersSubmissionKey.acceptInvitation(invitationId);

    emitState(
      state.copyWith(
        isSubmitting: true,
        submittingActionKey: actionKey,
        clearCompletedActionKey: true,
        clearErrorMessage: true,
      ),
    );

    try {
      await _repo.acceptCompanyInvitation(invitationId: invitationId);

      final currentUserInvitations = await _repo
          .getCurrentUserPendingInvitations();

      emitState(
        state.copyWith(
          currentUserInvitations: currentUserInvitations,
          isSubmitting: false,
          clearSubmittingActionKey: true,
          completedActionKey: actionKey,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emitState(
        state.copyWith(
          isSubmitting: false,
          clearSubmittingActionKey: true,
          clearCompletedActionKey: true,
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

    final actionKey = CompanyUsersSubmissionKey.cancelInvitation(invitationId);

    emitState(
      state.copyWith(
        isSubmitting: true,
        submittingActionKey: actionKey,
        clearCompletedActionKey: true,
        clearErrorMessage: true,
      ),
    );

    try {
      await _repo.cancelCompanyInvitation(invitationId: invitationId);

      await loadCompanyUsers(
        companyId: companyId,
        showLoader: false,
        completedActionKey: actionKey,
      );
    } catch (error) {
      emitState(
        state.copyWith(
          isSubmitting: false,
          clearSubmittingActionKey: true,
          clearCompletedActionKey: true,
          errorMessage: AppErrorMessage.fromError(
            error,
            fallback: 'Unable to cancel invitation. Please try again.',
          ),
        ),
      );
    }
  }
}
