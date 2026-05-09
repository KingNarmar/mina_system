import 'package:flutter/foundation.dart';
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
        final mediaSize = MediaQuery.sizeOf(context);
        final width = constraints.maxWidth;
        final shortestSide = mediaSize.shortestSide;

        final isCompactDevice = shortestSide < AppBreakpoints.tablet;
        final canUseDesktopLayout = _canUseDesktopLayout(defaultTargetPlatform);

        if (isCompactDevice) {
          return mobile;
        }

        if (canUseDesktopLayout && width >= AppBreakpoints.desktop) {
          return desktop;
        }

        return tablet;
      },
    );
  }

  bool _canUseDesktopLayout(TargetPlatform platform) {
    return switch (platform) {
      TargetPlatform.windows ||
      TargetPlatform.macOS ||
      TargetPlatform.linux => true,
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.fuchsia => false,
    };
  }
}
