import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/features/lookups/presentation/widgets/departments_tab.dart';
import 'package:mina_system/features/lookups/presentation/widgets/job_titles_tab.dart';

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
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Container(
              color: AppColors.card,
              child: const TabBar(
                labelColor: AppColors.accent,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.accent,
                tabs: [
                  Tab(text: 'Departments'),
                  Tab(text: 'Job Titles'),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(children: [DepartmentsTab(), JobTitlesTab()]),
            ),
          ],
        ),
      ),
    );
  }
}
