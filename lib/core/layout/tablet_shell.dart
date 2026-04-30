import 'package:flutter/material.dart';
import 'package:mina_system/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:mina_system/features/tools/presentation/screens/tools_screen.dart';
import 'package:mina_system/features/workers/presentation/screens/workers_screen.dart';

class TabletShell extends StatefulWidget {
  const TabletShell({super.key});

  @override
  State<TabletShell> createState() => _TabletShellState();
}

class _TabletShellState extends State<TabletShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    WorkersScreen(),
    ToolsScreen(),
  ];

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
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                label: Text('Workers'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.build_outlined),
                label: Text('Tools'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}
