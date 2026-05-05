import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_state.dart';
import 'package:mina_system/features/workers/presentation/widgets/layouts/workers_desktop_layout.dart';
import 'package:mina_system/features/workers/presentation/widgets/layouts/workers_mobile_layout.dart';

class WorkersScreen extends StatelessWidget {
  const WorkersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WorkersView();
  }
}

class _WorkersView extends StatelessWidget {
  const _WorkersView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkersCubit, WorkersState>(
      builder: (context, state) {
        final workers = state.filteredWorkers;

        return Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < AppBreakpoints.tablet;

                if (isMobile) {
                  return WorkersMobileLayout(workers: workers);
                }

                return WorkersDesktopLayout(workers: workers);
              },
            ),
            if (state.errorMessage != null)
              _WorkersErrorBanner(message: state.errorMessage!),
            if (state.isLoading) const _WorkersLoadingOverlay(),
          ],
        );
      },
    );
  }
}

class _WorkersErrorBanner extends StatelessWidget {
  const _WorkersErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
        ),
        child: Text(
          message,
          style: AppTextStyles.caption.copyWith(color: AppColors.error),
        ),
      ),
    );
  }
}

class _WorkersLoadingOverlay extends StatelessWidget {
  const _WorkersLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background.withValues(alpha: 0.72),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
