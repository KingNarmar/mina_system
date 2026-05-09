import 'package:flutter/material.dart';
import 'package:mina_system/core/routes/routes.dart';
import 'package:mina_system/core/theme/app_theme.dart';

class MinaSystem extends StatelessWidget {
  const MinaSystem({super.key, this.locale, this.appBuilder});

  final Locale? locale;
  final TransitionBuilder? appBuilder;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'M.I.N.A System',
      debugShowCheckedModeBanner: false,
      locale: locale,
      builder: appBuilder,
      routerConfig: Routes.router,
      theme: AppTheme.lightTheme,
    );
  }
}
