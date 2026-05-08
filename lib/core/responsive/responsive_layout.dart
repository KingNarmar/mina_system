import 'package:device_preview/device_preview.dart';
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
        final platform = DevicePreview.platform(context);

        final isCompactDevice = shortestSide < AppBreakpoints.tablet;
        final canUseDesktopLayout = _canUseDesktopLayout(platform);

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
