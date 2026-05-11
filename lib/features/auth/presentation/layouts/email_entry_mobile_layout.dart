import 'package:flutter/material.dart';
import 'package:mina_system/features/auth/presentation/widgets/email_entry_form.dart';

class EmailEntryMobileLayout extends StatelessWidget {
  const EmailEntryMobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(padding: EdgeInsets.all(20), child: EmailEntryForm()),
        ),
      ),
    );
  }
}
