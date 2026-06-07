import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/app_mode/app_mode.dart';
import 'package:mina_system/core/app_mode/app_mode_scope.dart';
import 'package:mina_system/core/layout/app_nav_item.dart';
import 'package:mina_system/core/layout/app_nav_items.dart';
import 'package:mina_system/core/layout/app_top_bar.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_cubit.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_state.dart';

class DesktopShell extends StatefulWidget {
  const DesktopShell({super.key});

  @override
  State<DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<DesktopShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appMode = AppModeScope.maybeOf(context) ?? AppMode.live;

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

        final navItems = AppNavItems.itemsForRole(
          currentRole,
          appMode: appMode,
        );

        if (navItems.isEmpty) {
          return const _NoAvailablePagesView();
        }

        final selectedIndex = _safeSelectedIndex(navItems);

        return Scaffold(
          body: Row(
            children: [
              _DesktopSidebar(
                items: navItems,
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
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

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<AppNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'M.I.N.A System',
            style: AppTextStyles.title.copyWith(color: AppColors.onPrimary),
          ),
          const Gap(32),
          ...List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = selectedIndex == index;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onDestinationSelected(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.onPrimary.withValues(alpha: 0.12)
                        : AppColors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(item.icon, color: AppColors.onPrimary, size: 20),
                      const Gap(12),
                      Text(
                        item.title,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
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
