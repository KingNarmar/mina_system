import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mina_system/core/layout/app_nav_item.dart';
import 'package:mina_system/core/layout/app_nav_items.dart';
import 'package:mina_system/core/routes/routes.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_icons.dart';
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

    context.go(Routes.login);
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
              previous.currentCompany?.name != current.currentCompany?.name ||
              previous.profile.fullName != current.profile.fullName ||
              previous.profile.email != current.profile.email ||
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
            title: _MobileTitle(
              title: navItems[selectedIndex].title,
              state: state,
            ),
            actions: [
              if (state is CurrentContextLoaded &&
                  state.hasMultipleCompanies &&
                  state.currentCompany != null)
                IconButton(
                  tooltip: 'Switch Company',
                  onPressed: () {
                    context.read<CurrentContextCubit>().openCompanySelection();
                  },
                  icon: const Icon(AppIcons.switchCompany),
                ),
              IconButton(
                tooltip: 'Logout',
                onPressed: _logout,
                icon: const Icon(AppIcons.logout),
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

class _MobileTitle extends StatelessWidget {
  const _MobileTitle({required this.title, required this.state});

  final String title;
  final CurrentContextState state;

  @override
  Widget build(BuildContext context) {
    final subtitle = _buildSubtitle();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        if (subtitle != null)
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  String? _buildSubtitle() {
    if (state is CurrentContextLoading) {
      return 'Loading company...';
    }

    if (state is CurrentContextFailure) {
      return 'Company unavailable';
    }

    if (state is! CurrentContextLoaded) {
      return null;
    }

    final loadedState = state as CurrentContextLoaded;
    final profile = loadedState.profile;
    final currentCompany = loadedState.currentCompany;

    final userName = profile.fullName?.trim();
    final companyName = currentCompany?.name.trim();

    if (companyName != null && companyName.isNotEmpty) {
      if (userName != null && userName.isNotEmpty) {
        return '$companyName • $userName';
      }

      return companyName;
    }

    if (userName != null && userName.isNotEmpty) {
      return userName;
    }

    return profile.email;
  }
}

class _NoAvailablePagesView extends StatelessWidget {
  const _NoAvailablePagesView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No pages are available for your current role.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
