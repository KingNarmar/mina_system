import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
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
    final mediaSize = MediaQuery.sizeOf(context);
    final isMobile = mediaSize.shortestSide < AppBreakpoints.tablet;
    final isCompactLandscape = isMobile && mediaSize.width > mediaSize.height;
    final isCompactInputMode = isCompactLandscape && _isLookupInputFocused;

    return DefaultTabController(
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
                if (state.errorMessage != null)
                  _LookupsErrorBanner(message: state.errorMessage!),
                Expanded(
                  child: Stack(
                    children: [
                      TabBarView(
                        children: [
                          DepartmentsTab(
                            isCompactInputMode: isCompactInputMode,
                            onLookupInputFocusChanged:
                                _onLookupInputFocusChanged,
                          ),
                          JobTitlesTab(
                            isCompactInputMode: isCompactInputMode,
                            onLookupInputFocusChanged:
                                _onLookupInputFocusChanged,
                          ),
                          ToolUnitsTab(
                            isCompactInputMode: isCompactInputMode,
                            onLookupInputFocusChanged:
                                _onLookupInputFocusChanged,
                          ),
                          ToolCategoriesTab(
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

class _LookupsErrorBanner extends StatelessWidget {
  const _LookupsErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Text(
        message,
        style: AppTextStyles.caption.copyWith(color: AppColors.error),
      ),
    );
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
