import 'package:flutter/material.dart';
import 'package:mina_system/core/layout/app_nav_items.dart';

class MobileShell extends StatefulWidget {
  const MobileShell({super.key});

  @override
  State<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends State<MobileShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppNavItems.items[_selectedIndex].page,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        destinations: AppNavItems.items
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                label: item.title,
              ),
            )
            .toList(),
      ),
    );
  }
}
