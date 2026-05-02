import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
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

class _LookupsView extends StatelessWidget {
  const _LookupsView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
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
            const Expanded(
              child: TabBarView(
                children: [
                  DepartmentsTab(),
                  JobTitlesTab(),
                  ToolUnitsTab(),
                  ToolCategoriesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
