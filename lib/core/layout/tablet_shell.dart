import 'package:flutter/material.dart';

class TabletShell extends StatelessWidget {
  const TabletShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: 0,
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
          const Expanded(child: Center(child: Text('Tablet Dashboard Shell'))),
        ],
      ),
    );
  }
}
