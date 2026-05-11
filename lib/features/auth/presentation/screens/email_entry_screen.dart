import 'package:flutter/material.dart';
import 'package:mina_system/core/responsive/responsive_layout.dart';
import 'package:mina_system/features/auth/presentation/layouts/email_entry_desktop_layout.dart';
import 'package:mina_system/features/auth/presentation/layouts/email_entry_mobile_layout.dart';
import 'package:mina_system/features/auth/presentation/layouts/email_entry_tablet_layout.dart';

class EmailEntryScreen extends StatelessWidget {
  const EmailEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: EmailEntryMobileLayout(),
      tablet: EmailEntryTabletLayout(),
      desktop: EmailEntryDesktopLayout(),
    );
  }
}
