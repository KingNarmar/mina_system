import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/layout/app_nav_item.dart';
import 'package:mina_system/core/layout/app_nav_items.dart';
import 'package:mina_system/core/layout/app_top_bar.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_cubit.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_state.dart';

class TabletShell extends StatefulWidget {
  const TabletShell({super.key});

  @override
  State<TabletShell> createState() => _TabletShellState();
}

class _TabletShellState extends State<TabletShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentContextCubit, CurrentContextState>(
      buildWhen: (previous, current) {
        if (previous is CurrentContextLoaded &&
            current is CurrentContextLoaded) {
          return previous.currentCompany?.role !=
                  current.currentCompany?.role ||
              previous.currentCompany?.id != current.currentCompany?.id;
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
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                destinations: navItems
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
                    AppTopBar(title: navItems[selectedIndex].title),
                    Expanded(child: navItems[selectedIndex].page),
                  ],
                ),
              ),
            ],
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
