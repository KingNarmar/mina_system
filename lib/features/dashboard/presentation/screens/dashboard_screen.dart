import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:mina_system/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:mina_system/features/dashboard/presentation/widgets/dashboard_stats_grid.dart';
import 'package:mina_system/features/dashboard/presentation/widgets/quick_action_card.dart';
import 'package:mina_system/features/dashboard/presentation/widgets/recent_transactions_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

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
              BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) {
                  final summary = state.summary;

                  return DashboardStatsGrid(
                    crossAxisCount: crossAxisCount,
                    width: constraints.maxWidth,
                    totalWorkers: summary.totalWorkers,
                    totalTools: summary.totalTools,
                    openCustodies: summary.openCustodies,
                    closedToday: summary.closedToday,
                  );
                },
              ),
              const Gap(24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < AppBreakpoints.tablet;

                  if (isMobile) {
                    return Column(
                      children: [
                        BlocBuilder<DashboardCubit, DashboardState>(
                          builder: (context, state) {
                            return RecentTransactionsCard(
                              transactions: state.summary.recentTransactions,
                            );
                          },
                        ),
                        const Gap(24),
                        const QuickActionsCard(),
                      ],
                    );
                  }

                  return const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: RecentTransactionsCard()),
                      Gap(24),
                      Expanded(flex: 1, child: QuickActionsCard()),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
