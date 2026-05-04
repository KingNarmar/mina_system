import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mina_system/app_root/app_root.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rdpyncdnihixuvxxitre.supabase.co',
    anonKey: 'sb_publishable_W17qAho0ihf9HXkiHp_MhA__-qsEFRl',
  );

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (BuildContext context) {
        return const MinaSystem();
      },
    ),
  );
}
