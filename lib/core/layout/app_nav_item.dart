import 'package:flutter/material.dart';

class AppNavItem {
  const AppNavItem({
    required this.title,
    required this.icon,
    required this.page,
  });

  final String title;
  final IconData icon;
  final Widget page;
}