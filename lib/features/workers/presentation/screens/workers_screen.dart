import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
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
    final currentRole = context.currentUserRole;

    final canCreateWorkers = CompanyRolePermissions.canCreateWorkers(
      currentRole,
    );

    final canUpdateWorkers = CompanyRolePermissions.canUpdateWorkers(
      currentRole,
    );

    final canDeleteWorkers = CompanyRolePermissions.canDeleteWorkers(
      currentRole,
    );

    return BlocListener<WorkersCubit, WorkersState>(
      listenWhen: (previous, current) {
        return previous.errorMessage != current.errorMessage &&
            current.errorMessage != null;
      },
      listener: (context, state) {
        AppMessage.showError(context, state.errorMessage!);
        context.read<WorkersCubit>().clearErrorMessage();
      },
      child: BlocBuilder<WorkersCubit, WorkersState>(
        builder: (context, state) {
          final workers = state.filteredWorkers;

          return Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final mediaSize = MediaQuery.sizeOf(context);
                  final isMobile =
                      mediaSize.shortestSide < AppBreakpoints.tablet;

                  if (isMobile) {
                    return WorkersMobileLayout(
                      workers: workers,
                      searchQuery: state.searchQuery,
                      canCreateWorkers: canCreateWorkers,
                      canUpdateWorkers: canUpdateWorkers,
                      canDeleteWorkers: canDeleteWorkers,
                    );
                  }

                  return WorkersDesktopLayout(
                    workers: workers,
                    searchQuery: state.searchQuery,
                    canCreateWorkers: canCreateWorkers,
                    canUpdateWorkers: canUpdateWorkers,
                    canDeleteWorkers: canDeleteWorkers,
                  );
                },
              ),
              if (state.isLoading || state.isSubmitting)
                const _WorkersLoadingOverlay(),
            ],
          );
        },
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
