import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/features/dashboard/presentation/widgets/dashboard_stat_card.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';

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
    final workers = context.watch<WorkersCubit>().state.workers;
    final tools = context.watch<ToolsCubit>().state.tools;
    final transactionsCubit = context.watch<TransactionsCubit>();

    final totalWorkers = workers.length;
    final totalTools = tools.length;

    final openCustodies =
        workers.fold<int>(
          0,
          (total, worker) => total + worker.activeCustodyCount,
        ) +
        tools.fold<int>(0, (total, tool) => total + tool.activeCustodyCount);

    final returnedToday = transactionsCubit.getReturnedTodayCount();

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: width < AppBreakpoints.tablet ? 2.55 : 2.8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        DashboardStatCard(
          title: 'Total Workers',
          value: totalWorkers.toString(),
          icon: Icons.people_outline,
          iconColor: AppColors.accent,
        ),
        DashboardStatCard(
          title: 'Total Tools',
          value: totalTools.toString(),
          icon: Icons.build_outlined,
          iconColor: AppColors.accent,
        ),
        DashboardStatCard(
          title: 'Open Custodies',
          value: openCustodies.toString(),
          icon: Icons.assignment_outlined,
          iconColor: AppColors.error,
        ),
        DashboardStatCard(
          title: 'Returned Today',
          value: returnedToday.toString(),
          icon: Icons.check_circle_outline,
          iconColor: AppColors.accent,
        ),
      ],
    );
  }
}
