import 'package:flutter/material.dart';

class MobileShell extends StatelessWidget {
  const MobileShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text('Mobile Dashboard Shell')),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
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
