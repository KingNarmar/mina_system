import 'package:flutter/material.dart';
import 'package:mina_system/core/layout/app_nav_item.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/features/company_settings/presentation/screens/company_settings_screen.dart';
import 'package:mina_system/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:mina_system/features/lookups/presentation/screens/lookups_screen.dart';
import 'package:mina_system/features/reports/presentation/screens/reports_screen.dart';
import 'package:mina_system/features/tools/presentation/screens/tools_screen.dart';
import 'package:mina_system/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:mina_system/features/workers/presentation/screens/workers_screen.dart';

abstract class AppNavItems {
  static const List<AppNavItem> items = [
    AppNavItem(
      title: 'Dashboard',
      icon: Icons.dashboard_outlined,
      page: DashboardScreen(),
      permission: CompanyPermission.viewDashboard,
    ),
    AppNavItem(
      title: 'Workers',
      icon: Icons.people_outline,
      page: WorkersScreen(),
      permission: CompanyPermission.viewWorkers,
    ),
    AppNavItem(
      title: 'Tools',
      icon: Icons.build_outlined,
      page: ToolsScreen(),
      permission: CompanyPermission.viewTools,
    ),
    AppNavItem(
      title: 'Transactions',
      icon: Icons.swap_horiz_outlined,
      page: TransactionsScreen(),
      permission: CompanyPermission.viewTransactions,
    ),
    AppNavItem(
      title: 'Reports',
      icon: Icons.analytics_outlined,
      page: ReportsScreen(),
      permission: CompanyPermission.viewReports,
    ),
    AppNavItem(
      title: 'Lookups',
      icon: Icons.tune_outlined,
      page: LookupsScreen(),
      permission: CompanyPermission.viewLookups,
    ),
    AppNavItem(
      title: 'Settings',
      icon: Icons.settings_outlined,
      page: CompanySettingsScreen(),
      permission: CompanyPermission.viewCompanySettings,
    ),
  ];

  static List<AppNavItem> itemsForRole(String? role) {
    return items
        .where((item) {
          return CompanyRolePermissions.hasPermission(role, item.permission);
        })
        .toList(growable: false);
  }
}
