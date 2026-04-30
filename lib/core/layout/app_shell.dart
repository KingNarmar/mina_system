import 'package:flutter/material.dart';
import 'package:mina_system/core/layout/desktop_shell.dart';
import 'package:mina_system/core/layout/mobile_shell.dart';
import 'package:mina_system/core/layout/tablet_shell.dart';
import 'package:mina_system/core/responsive/responsive_layout.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: MobileShell(),
      tablet: TabletShell(),
      desktop: DesktopShell(),
    );
  }
}
