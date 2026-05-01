import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
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

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < AppBreakpoints.tablet;

            if (isMobile) {
              return ToolsMobileLayout(tools: tools);
            }

            return ToolsDesktopLayout(tools: tools);
          },
        );
      },
    );
  }
}
