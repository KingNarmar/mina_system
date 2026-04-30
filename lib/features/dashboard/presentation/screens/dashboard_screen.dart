import 'package:flutter/material.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/features/dashboard/presentation/widgets/dashboard_stat_card.dart';
import 'package:mina_system/features/dashboard/presentation/widgets/quick_action_card.dart';
import 'package:mina_system/features/dashboard/presentation/widgets/recent_transactions_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final crossAxisCount = width < AppBreakpoints.tablet
        ? 1
        : width < AppBreakpoints.desktop
        ? 2
        : 4;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GridView.count(
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
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < AppBreakpoints.tablet;

              if (isMobile) {
                return const Column(
                  children: [
                    RecentTransactionsCard(),
                    SizedBox(height: 24),
                    QuickActionsCard(),
                  ],
                );
              }

              return const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: RecentTransactionsCard()),
                  SizedBox(width: 24),
                  Expanded(flex: 1, child: QuickActionsCard()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
