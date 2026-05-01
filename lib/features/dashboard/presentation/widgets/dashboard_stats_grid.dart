import 'package:flutter/material.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/features/dashboard/presentation/widgets/dashboard_stat_card.dart';

class DashboardStatsGrid extends StatelessWidget {
  const DashboardStatsGrid({
    super.key,
    required this.crossAxisCount,
    required this.width,
  });

  final int crossAxisCount;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: width < AppBreakpoints.tablet ? 2.55 : 2.8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        DashboardStatCard(
          title: 'Total Workers',
          value: '128',
          icon: Icons.people_outline,
          iconColor: AppColors.accent,
        ),
        DashboardStatCard(
          title: 'Total Tools',
          value: '342',
          icon: Icons.build_outlined,
          iconColor: AppColors.accent,
        ),
        DashboardStatCard(
          title: 'Open Custodies',
          value: '76',
          icon: Icons.assignment_outlined,
          iconColor: AppColors.error,
        ),
        DashboardStatCard(
          title: 'Returned Today',
          value: '18',
          icon: Icons.check_circle_outline,
          iconColor: AppColors.accent,
        ),
      ],
    );
  }
}
