import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:mina_system/features/auth/presentation/screens/login_screen.dart';

class MinaSystem extends StatelessWidget {
  const MinaSystem({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'M.I.N.A System',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      home: const LoginScreen(),
    );
  }
}
