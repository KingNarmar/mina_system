import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/layout/desktop_shell.dart';
import 'package:mina_system/core/layout/mobile_shell.dart';
import 'package:mina_system/core/layout/tablet_shell.dart';
import 'package:mina_system/core/responsive/responsive_layout.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_cubit.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_state.dart';
import 'package:mina_system/features/current_context/presentation/widgets/current_context_gate.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CurrentContextCubit()..loadCurrentContext(),
        ),
        BlocProvider(create: (_) => WorkersCubit()),
        BlocProvider(create: (_) => LookupsCubit()),
        BlocProvider(create: (_) => ToolsCubit()),
        BlocProvider(create: (_) => TransactionsCubit()),
      ],
      child: BlocListener<CurrentContextCubit, CurrentContextState>(
        listenWhen: (previous, current) {
          if (current is! CurrentContextLoaded) {
            return false;
          }

          if (current.currentCompany == null) {
            return false;
          }

          if (previous is CurrentContextLoaded) {
            return previous.currentCompany?.id != current.currentCompany?.id;
          }

          return true;
        },
        listener: (context, state) {
          if (state is! CurrentContextLoaded) {
            return;
          }

          final companyId = state.currentCompany?.id;

          if (companyId == null) {
            return;
          }

          context.read<LookupsCubit>().loadLookups(companyId: companyId);
        },
        child: const CurrentContextGate(
          child: ResponsiveLayout(
            mobile: MobileShell(),
            tablet: TabletShell(),
            desktop: DesktopShell(),
          ),
        ),
      ),
    );
  }
}
