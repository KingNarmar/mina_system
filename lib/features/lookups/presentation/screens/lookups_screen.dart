import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_state.dart';
import 'package:mina_system/features/lookups/presentation/widgets/departments_tab.dart';
import 'package:mina_system/features/lookups/presentation/widgets/job_titles_tab.dart';
import 'package:mina_system/features/lookups/presentation/widgets/tool_categories_tab.dart';
import 'package:mina_system/features/lookups/presentation/widgets/tool_units_tab.dart';

class LookupsScreen extends StatelessWidget {
  const LookupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LookupsView();
  }
}

class _LookupsView extends StatefulWidget {
  const _LookupsView();

  @override
  State<_LookupsView> createState() => _LookupsViewState();
}

class _LookupsViewState extends State<_LookupsView> {
  bool _isLookupInputFocused = false;

  @override
  Widget build(BuildContext context) {
    final currentRole = context.currentUserRole;

    final canCreateLookups = CompanyRolePermissions.canCreateLookups(
      currentRole,
    );

    final canDeleteLookups = CompanyRolePermissions.canDeleteLookups(
      currentRole,
    );

    final canRestoreLookups = canCreateLookups;

    final mediaSize = MediaQuery.sizeOf(context);
    final isMobile = mediaSize.shortestSide < AppBreakpoints.tablet;
    final isCompactLandscape = isMobile && mediaSize.width > mediaSize.height;
    final isCompactInputMode = isCompactLandscape && _isLookupInputFocused;

    return BlocListener<LookupsCubit, LookupsState>(
      listenWhen: (previous, current) {
        return previous.errorMessage != current.errorMessage &&
            current.errorMessage != null;
      },
      listener: (context, state) {
        AppMessage.showError(context, state.errorMessage!);
        context.read<LookupsCubit>().clearErrorMessage();
      },
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.background,
          body: BlocBuilder<LookupsCubit, LookupsState>(
            builder: (context, state) {
              return Column(
                children: [
                  if (!isCompactInputMode)
                    Container(
                      color: AppColors.card,
                      child: const TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        labelColor: AppColors.accent,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorColor: AppColors.accent,
                        tabs: [
                          Tab(text: 'Departments'),
                          Tab(text: 'Job Titles'),
                          Tab(text: 'Tool Units'),
                          Tab(text: 'Tool Categories'),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Stack(
                      children: [
                        TabBarView(
                          children: [
                            DepartmentsTab(
                              canCreateLookups: canCreateLookups,
                              canDeleteLookups: canDeleteLookups,
                              canRestoreLookups: canRestoreLookups,
                              isCompactInputMode: isCompactInputMode,
                              onLookupInputFocusChanged:
                                  _onLookupInputFocusChanged,
                            ),
                            JobTitlesTab(
                              canCreateLookups: canCreateLookups,
                              canDeleteLookups: canDeleteLookups,
                              canRestoreLookups: canRestoreLookups,
                              isCompactInputMode: isCompactInputMode,
                              onLookupInputFocusChanged:
                                  _onLookupInputFocusChanged,
                            ),
                            ToolUnitsTab(
                              canCreateLookups: canCreateLookups,
                              canDeleteLookups: canDeleteLookups,
                              canRestoreLookups: canRestoreLookups,
                              isCompactInputMode: isCompactInputMode,
                              onLookupInputFocusChanged:
                                  _onLookupInputFocusChanged,
                            ),
                            ToolCategoriesTab(
                              canCreateLookups: canCreateLookups,
                              canDeleteLookups: canDeleteLookups,
                              canRestoreLookups: canRestoreLookups,
                              isCompactInputMode: isCompactInputMode,
                              onLookupInputFocusChanged:
                                  _onLookupInputFocusChanged,
                            ),
                          ],
                        ),
                        if (state.isLoading) const _LookupsLoadingOverlay(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _onLookupInputFocusChanged(bool isFocused) {
    if (_isLookupInputFocused == isFocused) {
      return;
    }

    setState(() {
      _isLookupInputFocused = isFocused;
    });
  }
}

class _LookupsLoadingOverlay extends StatelessWidget {
  const _LookupsLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background.withValues(alpha: 0.72),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
