import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/permissions/company_role_permissions.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/utils/app_message.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_state.dart';
import 'package:mina_system/features/tools/presentation/widgets/layouts/tools_desktop_layout.dart';
import 'package:mina_system/features/tools/presentation/widgets/layouts/tools_mobile_layout.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ToolsView();
  }
}

class _ToolsView extends StatelessWidget {
  const _ToolsView();

  @override
  Widget build(BuildContext context) {
    final currentRole = context.currentUserRole;

    final canCreateTools = CompanyRolePermissions.canCreateTools(currentRole);
    final canUpdateTools = CompanyRolePermissions.canUpdateTools(currentRole);
    final canDeleteTools = CompanyRolePermissions.canDeleteTools(currentRole);

    return BlocListener<ToolsCubit, ToolsState>(
      listenWhen: (previous, current) {
        return previous.errorMessage != current.errorMessage &&
            current.errorMessage != null;
      },
      listener: (context, state) {
        AppMessage.showError(context, state.errorMessage!);
        context.read<ToolsCubit>().clearErrorMessage();
      },
      child: BlocBuilder<ToolsCubit, ToolsState>(
        builder: (context, state) {
          final tools = state.filteredTools;

          return Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final mediaSize = MediaQuery.sizeOf(context);
                  final isMobile =
                      mediaSize.shortestSide < AppBreakpoints.tablet;

                  if (isMobile) {
                    return ToolsMobileLayout(
                      tools: tools,
                      canCreateTools: canCreateTools,
                      canUpdateTools: canUpdateTools,
                      canDeleteTools: canDeleteTools,
                    );
                  }

                  return ToolsDesktopLayout(
                    tools: tools,
                    canCreateTools: canCreateTools,
                    canUpdateTools: canUpdateTools,
                    canDeleteTools: canDeleteTools,
                  );
                },
              ),
              if (state.isLoading || state.isSubmitting)
                const _ToolsLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }
}

class _ToolsLoadingOverlay extends StatelessWidget {
  const _ToolsLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background.withValues(alpha: 0.72),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
