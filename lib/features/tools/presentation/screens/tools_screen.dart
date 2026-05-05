import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_colors.dart';
import 'package:mina_system/core/theme/app_text_styles.dart';
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
    return BlocBuilder<ToolsCubit, ToolsState>(
      builder: (context, state) {
        final tools = state.filteredTools;

        return Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < AppBreakpoints.tablet;

                if (isMobile) {
                  return ToolsMobileLayout(tools: tools);
                }

                return ToolsDesktopLayout(tools: tools);
              },
            ),
            if (state.errorMessage != null)
              _ToolsErrorBanner(message: state.errorMessage!),
            if (state.isLoading || state.isSubmitting)
              const _ToolsLoadingOverlay(),
          ],
        );
      },
    );
  }
}

class _ToolsErrorBanner extends StatelessWidget {
  const _ToolsErrorBanner({required this.message});

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
