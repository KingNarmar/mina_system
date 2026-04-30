import 'package:flutter/material.dart';
import 'package:mina_system/core/layout/app_nav_items.dart';
import 'package:mina_system/core/layout/app_top_bar.dart';

class TabletShell extends StatefulWidget {
  const TabletShell({super.key});

  @override
  State<TabletShell> createState() => _TabletShellState();
}

class _TabletShellState extends State<TabletShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: AppNavItems.items
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    label: Text(item.title),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                AppTopBar(title: AppNavItems.items[_selectedIndex].title),
                Expanded(child: AppNavItems.items[_selectedIndex].page),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
