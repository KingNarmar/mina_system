import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mina_system/core/layout/app_nav_item.dart';
import 'package:mina_system/core/layout/app_nav_items.dart';
import 'package:mina_system/core/routes/routes.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_cubit.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_state.dart';
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

    context.go(Routes.emailEntry);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentContextCubit, CurrentContextState>(
      buildWhen: (previous, current) {
        if (previous is CurrentContextLoaded &&
            current is CurrentContextLoaded) {
          return previous.currentCompany?.role !=
                  current.currentCompany?.role ||
              previous.currentCompany?.id != current.currentCompany?.id ||
              previous.hasMultipleCompanies != current.hasMultipleCompanies;
        }

        return previous.runtimeType != current.runtimeType;
      },
      builder: (context, state) {
        final currentRole = state is CurrentContextLoaded
            ? state.currentCompany?.role
            : null;

        final navItems = AppNavItems.itemsForRole(currentRole);

        if (navItems.isEmpty) {
          return const _NoAvailablePagesView();
        }

        final selectedIndex = _safeSelectedIndex(navItems);

        return Scaffold(
          appBar: AppBar(
            title: Text(navItems[selectedIndex].title),
            actions: [
              if (state is CurrentContextLoaded &&
                  state.hasMultipleCompanies &&
                  state.currentCompany != null)
                IconButton(
                  tooltip: 'Switch Company',
                  onPressed: () {
                    context.read<CurrentContextCubit>().openCompanySelection();
                  },
                  icon: const Icon(Icons.swap_horiz),
                ),
              IconButton(
                tooltip: 'Logout',
                onPressed: _logout,
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: SafeArea(child: navItems[selectedIndex].page),
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            onDestinationSelected: (value) {
              setState(() {
                _selectedIndex = value;
              });
            },
            destinations: navItems
                .map(
                  (item) => NavigationDestination(
                    icon: Icon(item.icon),
                    label: _getMobileLabel(item.title),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  int _safeSelectedIndex(List<AppNavItem> navItems) {
    if (_selectedIndex < navItems.length) {
      return _selectedIndex;
    }

    return 0;
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

class _NoAvailablePagesView extends StatelessWidget {
  const _NoAvailablePagesView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No available pages for your current role.',
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
