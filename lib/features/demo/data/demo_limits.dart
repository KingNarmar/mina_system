abstract class DemoLimits {
  static const int maxWorkers = 10;
  static const int maxTools = 20;
  static const int maxTransactions = 50;
  static const int maxPendingInvitations = 3;

  static String workersLimitMessage() {
    return 'Demo mode limit reached: you can add up to $maxWorkers workers in the demo workspace. Reset demo data or request onboarding to continue with a live company workspace.';
  }

  static String toolsLimitMessage() {
    return 'Demo mode limit reached: you can add up to $maxTools tools in the demo workspace. Reset demo data or request onboarding to continue with a live company workspace.';
  }

  static String transactionsLimitMessage() {
    return 'Demo mode limit reached: you can add up to $maxTransactions transactions in the demo workspace. Reset demo data or request onboarding to continue with a live company workspace.';
  }

  static String invitationsLimitMessage() {
    return 'Demo mode limit reached: you can keep up to $maxPendingInvitations pending team invitations in the demo workspace. Cancel an invitation, reset demo data, or request onboarding to continue with a live company workspace.';
  }
}
