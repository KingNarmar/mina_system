import '../../data/models/company_invitation_model.dart';
import '../../data/models/company_member_model.dart';

class CompanyUsersState {
  const CompanyUsersState({
    this.members = const [],
    this.invitations = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final List<CompanyMemberModel> members;
  final List<CompanyInvitationModel> invitations;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  List<CompanyInvitationModel> get pendingInvitations {
    return invitations.where((invitation) {
      return invitation.status == 'pending';
    }).toList();
  }

  bool get hasError {
    return errorMessage != null && errorMessage!.trim().isNotEmpty;
  }

  CompanyUsersState copyWith({
    List<CompanyMemberModel>? members,
    List<CompanyInvitationModel>? invitations,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return CompanyUsersState(
      members: members ?? this.members,
      invitations: invitations ?? this.invitations,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
