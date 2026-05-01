import 'package:flutter/material.dart';
import 'package:mina_system/core/layout/app_nav_item.dart';
import 'package:mina_system/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:mina_system/features/tools/presentation/screens/tools_screen.dart';
import 'package:mina_system/features/workers/presentation/screens/workers_screen.dart';

abstract class AppNavItems {
  static const List<AppNavItem> items = [
    AppNavItem(
      title: 'Dashboard',
      icon: Icons.dashboard_outlined,
      page: DashboardScreen(),
    ),
    AppNavItem(
      title: 'Workers',
      icon: Icons.people_outline,
      page: WorkersScreen(),
    ),
    AppNavItem(title: 'Tools', icon: Icons.build_outlined, page: ToolsScreen()),
  ];
}
