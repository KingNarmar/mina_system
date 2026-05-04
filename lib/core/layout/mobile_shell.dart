import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mina_system/core/layout/app_nav_items.dart';
import 'package:mina_system/core/routes/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MobileShell extends StatefulWidget {
  const MobileShell({super.key});

  @override
  State<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends State<MobileShell> {
  int _selectedIndex = 0;

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();

    if (!mounted) return;

    context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppNavItems.items[_selectedIndex].title),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(child: AppNavItems.items[_selectedIndex].page),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        destinations: AppNavItems.items
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                label: _getMobileLabel(item.title),
              ),
            )
            .toList(),
      ),
    );
  }

  String _getMobileLabel(String title) {
    switch (title) {
      case 'Dashboard':
        return 'Home';
      case 'Transactions':
        return 'TRX';
      case 'Reports':
        return 'Reports';
      case 'Lookups':
        return 'Setup';
      default:
        return title;
    }
  }
}
