import 'package:mina_system/core/app_mode/app_mode.dart';
import 'package:mina_system/core/layout/app_nav_item.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/theme/app_icons.dart';
import 'package:mina_system/features/company_settings/presentation/screens/company_settings_screen.dart';
import 'package:mina_system/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:mina_system/features/lookups/presentation/screens/lookups_screen.dart';
import 'package:mina_system/features/reports/presentation/screens/reports_screen.dart';
import 'package:mina_system/features/team/presentation/screens/team_screen.dart';
import 'package:mina_system/features/tools/presentation/screens/tools_screen.dart';
import 'package:mina_system/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:mina_system/features/workers/presentation/screens/workers_screen.dart';

abstract class AppNavItems {
  static const List<AppNavItem> items = [
    AppNavItem(
      title: 'Dashboard',
      icon: AppIcons.dashboard,
      page: DashboardScreen(),
      permission: CompanyPermission.viewDashboard,
    ),
    AppNavItem(
      title: 'Workers',
      icon: AppIcons.workers,
      page: WorkersScreen(),
      permission: CompanyPermission.viewWorkers,
    ),
    AppNavItem(
      title: 'Tools',
      icon: AppIcons.tool,
      page: ToolsScreen(),
      permission: CompanyPermission.viewTools,
    ),
    AppNavItem(
      title: 'Transactions',
      icon: AppIcons.transactions,
      page: TransactionsScreen(),
      permission: CompanyPermission.viewTransactions,
    ),
    AppNavItem(
      title: 'Reports',
      icon: AppIcons.reports,
      page: ReportsScreen(),
      permission: CompanyPermission.viewReports,
    ),
    AppNavItem(
      title: 'Lookups',
      icon: AppIcons.lookups,
      page: LookupsScreen(),
      permission: CompanyPermission.viewLookups,
    ),
    AppNavItem(
      title: 'Team',
      icon: AppIcons.team,
      page: TeamScreen(),
      permission: CompanyPermission.viewTeam,
    ),
    AppNavItem(
      title: 'Settings',
      icon: AppIcons.settings,
      page: CompanySettingsScreen(),
      permission: CompanyPermission.viewCompanySettings,
    ),
  ];

  static const Set<String> _demoAllowedTitles = {
    'Dashboard',
    'Workers',
    'Tools',
    'Transactions',
    'Reports',
  };

  static List<AppNavItem> itemsForRole(
    String? role, {
    AppMode appMode = AppMode.live,
  }) {
    final sourceItems = appMode.isDemo
        ? items.where((item) => _demoAllowedTitles.contains(item.title))
        : items;

    return sourceItems
        .where((item) {
          return CompanyRolePermissions.hasPermission(role, item.permission);
        })
        .toList(growable: false);
  }
}
