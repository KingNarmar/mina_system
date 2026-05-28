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

  final int? crossAxisCount;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final summary = state.summary;

        return LayoutBuilder(
          builder: (context, constraints) {
            final effectiveWidth = width ?? constraints.maxWidth;
            final columns = crossAxisCount ?? _columnsForWidth(effectiveWidth);

            const spacing = 12.0;
            final itemWidth =
                (constraints.maxWidth - (spacing * (columns - 1))) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                SizedBox(
                  width: itemWidth,
                  height: 76,
                  child: DashboardStatCard(
                    title: 'Workers',
                    value: (totalWorkers ?? summary.totalWorkers).toString(),
                    icon: Icons.groups_outlined,
                    color: AppColors.accent,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  height: 76,
                  child: DashboardStatCard(
                    title: 'Tools',
                    value: (totalTools ?? summary.totalTools).toString(),
                    icon: Icons.handyman_outlined,
                    color: AppColors.success,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  height: 76,
                  child: DashboardStatCard(
                    title: 'Open Custody',
                    value: (openCustodies ?? summary.openCustodies).toString(),
                    icon: Icons.inventory_2_outlined,
                    color: AppColors.warning,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  height: 76,
                  child: DashboardStatCard(
                    title: 'Closed Today',
                    value: (closedToday ?? summary.closedToday).toString(),
                    icon: Icons.task_alt_outlined,
                    color: AppColors.error,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  int _columnsForWidth(double width) {
    if (width < 340) {
      return 1;
    }

    if (width < AppBreakpoints.tablet) {
      return 2;
    }

    return 4;
  }
}
