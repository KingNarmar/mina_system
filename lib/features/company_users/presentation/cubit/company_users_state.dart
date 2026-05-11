import '../../data/models/company_invitation_model.dart';
import '../../data/models/company_member_model.dart';

class CompanyUsersState {
  const CompanyUsersState({
    this.members = const [],
    this.companyInvitations = const [],
    this.currentUserInvitations = const [],
    this.isLoading = false,
    this.isCurrentUserInvitationsLoading = false,
    this.hasLoadedCurrentUserInvitations = false,
    this.isSubmitting = false,
    this.submittingActionKey,
    this.errorMessage,
  });

  final List<CompanyMemberModel> members;

  /// Invitations created for the currently managed company.
  /// Used inside Company Users / Team management by allowed roles.
  final List<CompanyInvitationModel> companyInvitations;

  /// Invitations addressed to the currently signed-in user.
  /// Used by invitation acceptance / workspace selection flows.
  final List<CompanyInvitationModel> currentUserInvitations;

  /// General loading for the initial Company Users / Team data load.
  final bool isLoading;

  /// Dedicated loading for entry-flow invitations that belong
  /// to the currently signed-in user only.
  final bool isCurrentUserInvitationsLoading;

  /// Prevents the entry gate from treating an empty list as
  /// "not loaded yet" after the request has already completed.
  final bool hasLoadedCurrentUserInvitations;

  /// General mutation flag.
  final bool isSubmitting;

  /// Identifies the exact mutation currently in progress so the UI can
  /// show loading only on the button that started the action.
  final String? submittingActionKey;

  final String? errorMessage;

  List<CompanyInvitationModel> get pendingCompanyInvitations {
    return companyInvitations.where((invitation) {
      return invitation.status == 'pending';
    }).toList();
  }

  List<CompanyInvitationModel> get pendingCurrentUserInvitations {
    return currentUserInvitations.where((invitation) {
      return invitation.status == 'pending';
    }).toList();
  }

  bool get hasError {
    return errorMessage != null && errorMessage!.trim().isNotEmpty;
  }

  bool isActionSubmitting(String actionKey) {
    return isSubmitting && submittingActionKey == actionKey;
  }

  CompanyUsersState copyWith({
    List<CompanyMemberModel>? members,
    List<CompanyInvitationModel>? companyInvitations,
    List<CompanyInvitationModel>? currentUserInvitations,
    bool? isLoading,
    bool? isCurrentUserInvitationsLoading,
    bool? hasLoadedCurrentUserInvitations,
    bool? isSubmitting,
    String? submittingActionKey,
    bool clearSubmittingActionKey = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return CompanyUsersState(
      members: members ?? this.members,
      companyInvitations: companyInvitations ?? this.companyInvitations,
      currentUserInvitations:
          currentUserInvitations ?? this.currentUserInvitations,
      isLoading: isLoading ?? this.isLoading,
      isCurrentUserInvitationsLoading:
          isCurrentUserInvitationsLoading ??
          this.isCurrentUserInvitationsLoading,
      hasLoadedCurrentUserInvitations:
          hasLoadedCurrentUserInvitations ??
          this.hasLoadedCurrentUserInvitations,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submittingActionKey: clearSubmittingActionKey
          ? null
          : submittingActionKey ?? this.submittingActionKey,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

abstract class CompanyUsersSubmissionKey {
  static const String invite = 'invite';

  static String changeRole(String memberId) {
    return 'change-role:$memberId';
  }

  static String deactivateMember(String memberId) {
    return 'deactivate-member:$memberId';
  }

  static String reactivateMember(String memberId) {
    return 'reactivate-member:$memberId';
  }

  static String cancelInvitation(String invitationId) {
    return 'cancel-invitation:$invitationId';
  }

  static String acceptInvitation(String invitationId) {
    return 'accept-invitation:$invitationId';
  }
}
