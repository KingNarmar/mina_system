enum CompanyPermission {
  viewDashboard,

  viewWorkers,
  manageWorkers,
  createWorkers,
  updateWorkers,
  deleteWorkers,

  viewTools,
  manageTools,
  createTools,
  updateTools,
  deleteTools,

  viewTransactions,
  createTransactions,
  updateTransactions,

  uploadApprovalDocument,
  approveLostDamaged,
  rejectLostDamaged,
  settleLostDamaged,

  viewCustodyBalance,
  viewToolSummary,

  viewReports,
  generateReports,

  viewLookups,
  manageLookups,
  createLookups,
  deleteLookups,

  viewCompanySettings,
  manageCompanyProfile,
  uploadCompanyLogo,
  manageReportSettings,
  manageDocumentTemplates,

  viewTeam,
  manageTeam,

  viewCompanyUsers,
  manageCompanyUsers,
  inviteUsers,
  cancelInvitations,
  changeMemberRole,
  deactivateMember,
  reactivateMember,
  removeMemberAccess,
}

abstract class CompanyRoles {
  static const String owner = 'owner';
  static const String admin = 'admin';
  static const String warehouseManager = 'warehouse_manager';
  static const String warehouseUser = 'warehouse_user';
  static const String viewer = 'viewer';

  static const List<String> all = [
    owner,
    admin,
    warehouseManager,
    warehouseUser,
    viewer,
  ];

  static String normalize(String? role) {
    return role?.trim().toLowerCase() ?? '';
  }

  static bool isKnownRole(String? role) {
    return all.contains(normalize(role));
  }

  static String label(String? role) {
    switch (normalize(role)) {
      case owner:
        return 'Owner';
      case admin:
        return 'Admin';
      case warehouseManager:
        return 'Warehouse Manager';
      case warehouseUser:
        return 'Warehouse User';
      case viewer:
        return 'Viewer';
      default:
        return 'Unknown Role';
    }
  }
}

abstract class CompanyRolePermissions {
  static const Set<CompanyPermission> _viewerReadOnlyPermissions = {
    CompanyPermission.viewDashboard,

    CompanyPermission.viewWorkers,
    CompanyPermission.viewTools,
    CompanyPermission.viewTransactions,

    CompanyPermission.viewCustodyBalance,
    CompanyPermission.viewToolSummary,

    CompanyPermission.viewReports,
    CompanyPermission.generateReports,

    CompanyPermission.viewLookups,

    CompanyPermission.viewTeam,
    CompanyPermission.viewCompanyUsers,
  };

  static final Map<String, Set<CompanyPermission>> _basePermissions = {
    CompanyRoles.owner: CompanyPermission.values.toSet(),

    CompanyRoles.admin: {
      CompanyPermission.viewDashboard,

      CompanyPermission.viewWorkers,
      CompanyPermission.manageWorkers,
      CompanyPermission.createWorkers,
      CompanyPermission.updateWorkers,
      CompanyPermission.deleteWorkers,

      CompanyPermission.viewTools,
      CompanyPermission.manageTools,
      CompanyPermission.createTools,
      CompanyPermission.updateTools,
      CompanyPermission.deleteTools,

      CompanyPermission.viewTransactions,
      CompanyPermission.createTransactions,
      CompanyPermission.updateTransactions,

      CompanyPermission.uploadApprovalDocument,
      CompanyPermission.approveLostDamaged,
      CompanyPermission.rejectLostDamaged,
      CompanyPermission.settleLostDamaged,

      CompanyPermission.viewCustodyBalance,
      CompanyPermission.viewToolSummary,

      CompanyPermission.viewReports,
      CompanyPermission.generateReports,

      CompanyPermission.viewLookups,
      CompanyPermission.manageLookups,
      CompanyPermission.createLookups,
      CompanyPermission.deleteLookups,

      CompanyPermission.viewCompanySettings,
      CompanyPermission.manageCompanyProfile,
      CompanyPermission.uploadCompanyLogo,
      CompanyPermission.manageReportSettings,
      CompanyPermission.manageDocumentTemplates,

      CompanyPermission.viewTeam,
      CompanyPermission.manageTeam,

      CompanyPermission.viewCompanyUsers,
      CompanyPermission.manageCompanyUsers,
      CompanyPermission.inviteUsers,
      CompanyPermission.cancelInvitations,
      CompanyPermission.changeMemberRole,
      CompanyPermission.deactivateMember,
      CompanyPermission.reactivateMember,
      CompanyPermission.removeMemberAccess,
    },

    CompanyRoles.warehouseManager: {
      CompanyPermission.viewDashboard,

      CompanyPermission.viewWorkers,
      CompanyPermission.manageWorkers,
      CompanyPermission.createWorkers,
      CompanyPermission.updateWorkers,
      CompanyPermission.deleteWorkers,

      CompanyPermission.viewTools,
      CompanyPermission.manageTools,
      CompanyPermission.createTools,
      CompanyPermission.updateTools,
      CompanyPermission.deleteTools,

      CompanyPermission.viewTransactions,
      CompanyPermission.createTransactions,
      CompanyPermission.updateTransactions,

      CompanyPermission.uploadApprovalDocument,
      CompanyPermission.approveLostDamaged,
      CompanyPermission.rejectLostDamaged,
      CompanyPermission.settleLostDamaged,

      CompanyPermission.viewCustodyBalance,
      CompanyPermission.viewToolSummary,

      CompanyPermission.viewReports,
      CompanyPermission.generateReports,

      CompanyPermission.viewLookups,
      CompanyPermission.manageLookups,
      CompanyPermission.createLookups,
      CompanyPermission.deleteLookups,

      CompanyPermission.viewTeam,
      CompanyPermission.manageTeam,
      CompanyPermission.deactivateMember,
      CompanyPermission.reactivateMember,
    },

    CompanyRoles.warehouseUser: {
      CompanyPermission.viewDashboard,

      CompanyPermission.viewWorkers,
      CompanyPermission.viewTools,

      CompanyPermission.viewTransactions,
      CompanyPermission.createTransactions,

      CompanyPermission.viewCustodyBalance,
      CompanyPermission.viewToolSummary,

      CompanyPermission.viewReports,
      CompanyPermission.generateReports,
    },

    CompanyRoles.viewer: _viewerReadOnlyPermissions,
  };

  static bool hasPermission(String? role, CompanyPermission permission) {
    final normalizedRole = CompanyRoles.normalize(role);
    final permissions = _basePermissions[normalizedRole];

    if (permissions == null) {
      return false;
    }

    return permissions.contains(permission);
  }

  static Set<CompanyPermission> permissionsForRole(String? role) {
    final normalizedRole = CompanyRoles.normalize(role);

    return Set.unmodifiable(_basePermissions[normalizedRole] ?? const {});
  }

  static bool isOwner(String? role) {
    return CompanyRoles.normalize(role) == CompanyRoles.owner;
  }

  static bool isAdmin(String? role) {
    return CompanyRoles.normalize(role) == CompanyRoles.admin;
  }

  static bool isWarehouseManager(String? role) {
    return CompanyRoles.normalize(role) == CompanyRoles.warehouseManager;
  }

  static bool isWarehouseUser(String? role) {
    return CompanyRoles.normalize(role) == CompanyRoles.warehouseUser;
  }

  static bool isViewer(String? role) {
    return CompanyRoles.normalize(role) == CompanyRoles.viewer;
  }

  static bool canViewDashboard(String? role) {
    return hasPermission(role, CompanyPermission.viewDashboard);
  }

  static bool canViewWorkers(String? role) {
    return hasPermission(role, CompanyPermission.viewWorkers);
  }

  static bool canManageWorkers(String? role) {
    return hasPermission(role, CompanyPermission.manageWorkers);
  }

  static bool canCreateWorkers(String? role) {
    return hasPermission(role, CompanyPermission.createWorkers);
  }

  static bool canUpdateWorkers(String? role) {
    return hasPermission(role, CompanyPermission.updateWorkers);
  }

  static bool canDeleteWorkers(String? role) {
    return hasPermission(role, CompanyPermission.deleteWorkers);
  }

  static bool canViewTools(String? role) {
    return hasPermission(role, CompanyPermission.viewTools);
  }

  static bool canManageTools(String? role) {
    return hasPermission(role, CompanyPermission.manageTools);
  }

  static bool canCreateTools(String? role) {
    return hasPermission(role, CompanyPermission.createTools);
  }

  static bool canUpdateTools(String? role) {
    return hasPermission(role, CompanyPermission.updateTools);
  }

  static bool canDeleteTools(String? role) {
    return hasPermission(role, CompanyPermission.deleteTools);
  }

  static bool canViewTransactions(String? role) {
    return hasPermission(role, CompanyPermission.viewTransactions);
  }

  static bool canCreateTransactions(String? role) {
    return hasPermission(role, CompanyPermission.createTransactions);
  }

  static bool canUpdateTransactions(String? role) {
    return hasPermission(role, CompanyPermission.updateTransactions);
  }

  static bool canUploadApprovalDocument(String? role) {
    return hasPermission(role, CompanyPermission.uploadApprovalDocument);
  }

  static bool canApproveLostDamaged(String? role) {
    return hasPermission(role, CompanyPermission.approveLostDamaged);
  }

  static bool canRejectLostDamaged(String? role) {
    return hasPermission(role, CompanyPermission.rejectLostDamaged);
  }

  static bool canSettleLostDamaged(String? role) {
    return hasPermission(role, CompanyPermission.settleLostDamaged);
  }

  static bool canViewCustodyBalance(String? role) {
    return hasPermission(role, CompanyPermission.viewCustodyBalance);
  }

  static bool canViewToolSummary(String? role) {
    return hasPermission(role, CompanyPermission.viewToolSummary);
  }

  static bool canViewReports(String? role) {
    return hasPermission(role, CompanyPermission.viewReports);
  }

  static bool canGenerateReports(String? role) {
    return hasPermission(role, CompanyPermission.generateReports);
  }

  static bool canViewLookups(String? role) {
    return hasPermission(role, CompanyPermission.viewLookups);
  }

  static bool canManageLookups(String? role) {
    return hasPermission(role, CompanyPermission.manageLookups);
  }

  static bool canCreateLookups(String? role) {
    return hasPermission(role, CompanyPermission.createLookups);
  }

  static bool canDeleteLookups(String? role) {
    return hasPermission(role, CompanyPermission.deleteLookups);
  }

  static bool canViewCompanySettings(String? role) {
    return hasPermission(role, CompanyPermission.viewCompanySettings);
  }

  static bool canManageCompanyProfile(String? role) {
    return hasPermission(role, CompanyPermission.manageCompanyProfile);
  }

  static bool canUploadCompanyLogo(String? role) {
    return hasPermission(role, CompanyPermission.uploadCompanyLogo);
  }

  static bool canManageReportSettings(String? role) {
    return hasPermission(role, CompanyPermission.manageReportSettings);
  }

  static bool canManageDocumentTemplates(String? role) {
    return hasPermission(role, CompanyPermission.manageDocumentTemplates);
  }

  static bool canViewTeam(String? role) {
    return hasPermission(role, CompanyPermission.viewTeam);
  }

  static bool canManageTeam(String? role) {
    return hasPermission(role, CompanyPermission.manageTeam);
  }

  static bool canViewCompanyUsers(String? role) {
    return hasPermission(role, CompanyPermission.viewCompanyUsers);
  }

  static bool canManageCompanyUsers(String? role) {
    return hasPermission(role, CompanyPermission.manageCompanyUsers);
  }

  static bool canInviteUsers(String? role) {
    return hasPermission(role, CompanyPermission.inviteUsers);
  }

  static bool canCancelInvitations(String? role) {
    return hasPermission(role, CompanyPermission.cancelInvitations);
  }

  static bool canChangeMemberRole(String? role) {
    return hasPermission(role, CompanyPermission.changeMemberRole);
  }

  static bool canDeactivateMember(String? role) {
    return hasPermission(role, CompanyPermission.deactivateMember);
  }

  static bool canReactivateMember(String? role) {
    return hasPermission(role, CompanyPermission.reactivateMember);
  }

  static bool canManageMemberLifecycle(String? role) {
    return canDeactivateMember(role) || canReactivateMember(role);
  }

  static bool canRemoveMemberAccess(String? role) {
    return hasPermission(role, CompanyPermission.removeMemberAccess);
  }

  static List<String> assignableRolesFor(String? actorRole) {
    switch (CompanyRoles.normalize(actorRole)) {
      case CompanyRoles.owner:
        return const [
          CompanyRoles.admin,
          CompanyRoles.warehouseManager,
          CompanyRoles.warehouseUser,
          CompanyRoles.viewer,
        ];

      case CompanyRoles.admin:
        return const [
          CompanyRoles.warehouseManager,
          CompanyRoles.warehouseUser,
          CompanyRoles.viewer,
        ];

      default:
        return const [];
    }
  }

  static bool canAssignRole({
    required String? actorRole,
    required String targetRole,
  }) {
    return assignableRolesFor(
      actorRole,
    ).contains(CompanyRoles.normalize(targetRole));
  }

  static List<String> manageableTargetRolesFor(String? actorRole) {
    switch (CompanyRoles.normalize(actorRole)) {
      case CompanyRoles.owner:
        return const [
          CompanyRoles.admin,
          CompanyRoles.warehouseManager,
          CompanyRoles.warehouseUser,
          CompanyRoles.viewer,
        ];

      case CompanyRoles.admin:
        return const [
          CompanyRoles.warehouseManager,
          CompanyRoles.warehouseUser,
          CompanyRoles.viewer,
        ];

      case CompanyRoles.warehouseManager:
        return const [CompanyRoles.warehouseUser, CompanyRoles.viewer];

      default:
        return const [];
    }
  }

  static bool canManageTargetRole({
    required String? actorRole,
    required String? targetRole,
  }) {
    final normalizedTargetRole = CompanyRoles.normalize(targetRole);

    return manageableTargetRolesFor(actorRole).contains(normalizedTargetRole);
  }
}
