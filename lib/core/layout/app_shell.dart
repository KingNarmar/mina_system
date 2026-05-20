import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/layout/desktop_shell.dart';
import 'package:mina_system/core/layout/mobile_shell.dart';
import 'package:mina_system/core/layout/tablet_shell.dart';
import 'package:mina_system/core/network/presentation/cubit/network_status_cubit.dart';
import 'package:mina_system/core/network/presentation/widgets/global_offline_banner.dart';
import 'package:mina_system/core/realtime/company_realtime_sync_scope.dart';
import 'package:mina_system/core/realtime/user_context_realtime_sync_scope.dart';
import 'package:mina_system/core/responsive/responsive_layout.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_cubit.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_cubit.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_cubit.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_state.dart';
import 'package:mina_system/features/current_context/presentation/widgets/current_context_gate.dart';
import 'package:mina_system/features/dashboard/presentation/cubit/dashboard_cubit.dart';
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
        BlocProvider(create: (_) => NetworkStatusCubit()..startWatching()),
        BlocProvider(
          create: (_) => CurrentContextCubit()..loadCurrentContext(),
        ),
        BlocProvider(create: (_) => WorkersCubit()),
        BlocProvider(create: (_) => LookupsCubit()),
        BlocProvider(create: (_) => ToolsCubit()),
        BlocProvider(create: (_) => TransactionsCubit()),
        BlocProvider(create: (_) => DashboardCubit()),
        BlocProvider(create: (_) => CompanySettingsCubit()),
        BlocProvider(create: (_) => CompanyUsersCubit()),
      ],
      child: const _AppShellView(),
    );
  }
}

class _AppShellView extends StatelessWidget {
  const _AppShellView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<CurrentContextCubit, CurrentContextState>(
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
        context.read<WorkersCubit>().loadWorkers(companyId: companyId);
        context.read<ToolsCubit>().loadTools(companyId: companyId);
        context.read<TransactionsCubit>().loadTransactions(
          companyId: companyId,
        );
        context.read<DashboardCubit>().loadDashboardSummary(
          companyId: companyId,
        );
        context.read<CompanySettingsCubit>().loadCompanyProfile(
          companyId: companyId,
        );
        context.read<CompanyUsersCubit>().loadCompanyUsers(
          companyId: companyId,
        );
      },
      child: const GlobalOfflineBanner(
        child: UserContextRealtimeSyncScope(
          child: CurrentContextGate(
            child: CompanyRealtimeSyncScope(
              child: ResponsiveLayout(
                mobile: MobileShell(),
                tablet: TabletShell(),
                desktop: DesktopShell(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
