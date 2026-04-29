import 'package:flutter/material.dart';
import 'package:mina_system/core/responsive/app_breakpoints.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width < AppBreakpoints.tablet) {
          return mobile;
        } else if (width < AppBreakpoints.desktop) {
          return tablet;
        } else {
          return desktop;
        }
      },
    );
  }
}
