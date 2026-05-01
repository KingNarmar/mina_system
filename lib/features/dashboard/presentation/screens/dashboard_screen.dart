import 'package:flutter/material.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/features/dashboard/presentation/widgets/dashboard_stats_grid.dart';
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
          DashboardStatsGrid(crossAxisCount: crossAxisCount, width: width),
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
