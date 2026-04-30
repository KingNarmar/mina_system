import 'package:flutter/material.dart';
import 'package:mina_system/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:mina_system/features/tools/presentation/screens/tools_screen.dart';
import 'package:mina_system/features/workers/presentation/screens/workers_screen.dart';

class MobileShell extends StatefulWidget {
  const MobileShell({super.key});

  @override
  State<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends State<MobileShell> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const DashboardScreen(),
    const WorkersScreen(),
    const ToolsScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            label: 'Workers',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            label: 'Tools',
          ),
        ],
      ),
    );
  }
}
