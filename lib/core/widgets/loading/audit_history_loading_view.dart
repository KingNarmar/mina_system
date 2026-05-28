import 'package:flutter/material.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/widgets/loading/app_skeleton.dart';

class AuditHistoryLoadingView extends StatelessWidget {
  const AuditHistoryLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: 6,
        separatorBuilder: (context, index) {
          return const SizedBox(height: 10);
        },
        itemBuilder: (context, index) {
          return const _AuditHistoryTileSkeleton();
        },
      ),
    );
  }
}

class _AuditHistoryTileSkeleton extends StatelessWidget {
  const _AuditHistoryTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeletonBox(width: 38, height: 38, borderRadius: 14),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonLine(height: 13),
                SizedBox(height: 8),
                AppSkeletonLine(width: 240, height: 11),
                SizedBox(height: 8),
                AppSkeletonLine(width: 170, height: 10),
                SizedBox(height: 12),
                Row(
                  children: [
                    AppSkeletonBox(width: 74, height: 26, borderRadius: 999),
                    SizedBox(width: 8),
                    AppSkeletonBox(width: 92, height: 26, borderRadius: 999),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
