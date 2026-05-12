import 'package:flutter/material.dart';
import 'package:mina_system/app_root/app_root.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();

  await Supabase.initialize(
    url: 'https://rdpyncdnihixuvxxitre.supabase.co',
    anonKey: 'sb_publishable_W17qAho0ihf9HXkiHp_MhA__-qsEFRl',
  );

  runApp(const MinaSystem());
}
