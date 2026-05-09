import 'package:flutter/material.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';

class AppNavItem {
  const AppNavItem({
    required this.title,
    required this.icon,
    required this.page,
    required this.permission,
  });

  final String title;
  final IconData icon;
  final Widget page;
  final CompanyPermission permission;
}
