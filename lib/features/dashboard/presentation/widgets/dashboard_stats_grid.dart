import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:mina_system/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:mina_system/features/dashboard/presentation/widgets/dashboard_stat_card.dart';

class DashboardStatsGrid extends StatelessWidget {
  const DashboardStatsGrid({
    super.key,
    this.totalWorkers,
    this.totalTools,
    this.openCustodies,
    this.closedToday,
    this.crossAxisCount,
    this.width,
  });

  final int? totalWorkers;
  final int? totalTools;
  final int? openCustodies;
  final int? closedToday;

  /// Kept for compatibility with the current DashboardScreen.
  final int? crossAxisCount;

  /// Kept for compatibility with the current DashboardScreen.
  final double? width;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final summary = state.summary;

        return LayoutBuilder(
          builder: (context, constraints) {
            final effectiveWidth = width ?? constraints.maxWidth;

            final effectiveCrossAxisCount =
                crossAxisCount ??
                (effectiveWidth < AppBreakpoints.tablet ? 1 : 4);

            return GridView.count(
              crossAxisCount: effectiveCrossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: effectiveWidth < AppBreakpoints.tablet
                  ? 3.2
                  : 1.65,
              children: [
                DashboardStatCard(
                  title: 'Total Workers',
                  value: (totalWorkers ?? summary.totalWorkers).toString(),
                  icon: Icons.groups_outlined,
                  color: AppColors.accent,
                ),
                DashboardStatCard(
                  title: 'Total Tools',
                  value: (totalTools ?? summary.totalTools).toString(),
                  icon: Icons.handyman_outlined,
                  color: AppColors.success,
                ),
                DashboardStatCard(
                  title: 'Open Custodies',
                  value: (openCustodies ?? summary.openCustodies).toString(),
                  icon: Icons.inventory_2_outlined,
                  color: AppColors.warning,
                ),
                DashboardStatCard(
                  title: 'Closed Today',
                  value: (closedToday ?? summary.closedToday).toString(),
                  icon: Icons.task_alt_outlined,
                  color: AppColors.error,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
