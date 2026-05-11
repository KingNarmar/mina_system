part of 'company_users_cubit.dart';

extension CompanyUsersCubitMembers on CompanyUsersCubit {
  Future<void> changeCompanyMemberRole({
    required String companyId,
    required String memberId,
    required String newRole,
  }) async {
    final canContinue = await _ensureOnline();

    if (!canContinue) {
      return;
    }

    final actionKey = CompanyUsersSubmissionKey.changeRole(memberId);

    emitState(
      state.copyWith(
        isSubmitting: true,
        submittingActionKey: actionKey,
        clearCompletedActionKey: true,
        clearErrorMessage: true,
      ),
    );

    try {
      await _repo.changeCompanyMemberRole(
        companyId: companyId,
        memberId: memberId,
        newRole: newRole,
      );

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

    final actionKey = CompanyUsersSubmissionKey.deactivateMember(memberId);

    emitState(
      state.copyWith(
        isSubmitting: true,
        submittingActionKey: actionKey,
        clearCompletedActionKey: true,
        clearErrorMessage: true,
      ),
    );

    try {
      await _repo.deactivateCompanyMember(
        companyId: companyId,
        memberId: memberId,
      );

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

    final actionKey = CompanyUsersSubmissionKey.reactivateMember(memberId);

    emitState(
      state.copyWith(
        isSubmitting: true,
        submittingActionKey: actionKey,
        clearCompletedActionKey: true,
        clearErrorMessage: true,
      ),
    );

    try {
      await _repo.reactivateCompanyMember(
        companyId: companyId,
        memberId: memberId,
      );

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
            fallback: 'Unable to reactivate member. Please try again.',
          ),
        ),
      );
    }
  }
}
