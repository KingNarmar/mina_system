import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:mina_system/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:mina_system/features/dashboard/presentation/widgets/dashboard_loading_view.dart';
import 'package:mina_system/features/dashboard/presentation/widgets/dashboard_overview_panel.dart';
import 'package:mina_system/features/dashboard/presentation/widgets/quick_action_card.dart';
import 'package:mina_system/features/dashboard/presentation/widgets/recent_transactions_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < AppBreakpoints.tablet;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
              if (state.isLoading) {
                return DashboardLoadingView(isMobile: isMobile);
              }

              final summary = state.summary;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DashboardOverviewPanel(
                    totalWorkers: summary.totalWorkers,
                    totalTools: summary.totalTools,
                    openCustodies: summary.openCustodies,
                    closedToday: summary.closedToday,
                  ),
                  const Gap(18),
                  if (isMobile)
                    Column(
                      children: [
                        RecentTransactionsCard(
                          transactions: summary.recentTransactions,
                        ),
                        const Gap(16),
                        const QuickActionsCard(),
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 7,
                          child: RecentTransactionsCard(
                            transactions: summary.recentTransactions,
                          ),
                        ),
                        const Gap(18),
                        const Expanded(flex: 4, child: QuickActionsCard()),
                      ],
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
