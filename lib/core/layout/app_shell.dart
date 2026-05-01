import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/layout/desktop_shell.dart';
import 'package:mina_system/core/layout/mobile_shell.dart';
import 'package:mina_system/core/layout/tablet_shell.dart';
import 'package:mina_system/core/responsive/responsive_layout.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => WorkersCubit()),
        BlocProvider(create: (_) => LookupsCubit()),
      ],
      child: const ResponsiveLayout(
        mobile: MobileShell(),
        tablet: TabletShell(),
        desktop: DesktopShell(),
      ),
    );
  }
}
