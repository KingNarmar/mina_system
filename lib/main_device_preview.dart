import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mina_system/app_root/app_root.dart';
import 'package:mina_system/core/config/app_environment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();

  AppEnvironment.validate();

  if (kDebugMode) {
    debugPrint('Mina System environment: ${AppEnvironment.name}');
  }

  await Supabase.initialize(
    url: AppEnvironment.supabaseUrl,
    anonKey: AppEnvironment.supabaseAnonKey,
  );

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (BuildContext context) {
        return MinaSystem(
          locale: DevicePreview.locale(context),
          appBuilder: DevicePreview.appBuilder,
        );
      },
    ),
  );
}
