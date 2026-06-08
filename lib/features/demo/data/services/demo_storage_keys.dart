abstract class DemoStorageKeys {
  static const String isInitialized = 'demo_is_initialized';

  static const String departments = 'demo_departments';
  static const String jobTitles = 'demo_job_titles';
  static const String toolCategories = 'demo_tool_categories';
  static const String toolUnits = 'demo_tool_units';
  static const String workers = 'demo_workers';
  static const String tools = 'demo_tools';
  static const String transactions = 'demo_transactions';

  static const String companyProfile = 'demo_company_profile';
  static const String reportSettings = 'demo_report_settings';
  static const String signedReportsMetadata = 'demo_signed_reports_metadata';

  static const String companyMembers = 'demo_company_members';
  static const String companyInvitations = 'demo_company_invitations';
  static const String companyUserAuditLogs = 'demo_company_user_audit_logs';

  static const List<String> allKeys = [
    isInitialized,
    departments,
    jobTitles,
    toolCategories,
    toolUnits,
    workers,
    tools,
    transactions,
    companyProfile,
    reportSettings,
    signedReportsMetadata,
    companyMembers,
    companyInvitations,
    companyUserAuditLogs,
  ];
}
