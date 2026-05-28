import 'package:flutter/material.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';
import 'package:mina_system/core/theme/app_colors.dart';

import '../../../../dashboard/presentation/widgets/dashboard_loading_view.dart';

class CurrentContextLoadingView extends StatelessWidget {
  const CurrentContextLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < AppBreakpoints.tablet;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: DashboardLoadingView(isMobile: isMobile),
            );
          },
        ),
      ),
    );
  }
}
