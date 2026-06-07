import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/app_mode/app_mode.dart';
import 'package:mina_system/core/app_mode/app_mode_scope.dart';
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
    final appMode = AppModeScope.maybeOf(context) ?? AppMode.live;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => _createNetworkStatusCubit(appMode)),
        BlocProvider(create: (_) => _createCurrentContextCubit(appMode)),
        BlocProvider(create: (_) => WorkersCubit()),
        BlocProvider(create: (_) => LookupsCubit()),
        BlocProvider(create: (_) => ToolsCubit()),
        BlocProvider(create: (_) => TransactionsCubit()),
        BlocProvider(create: (_) => DashboardCubit()),
        BlocProvider(create: (_) => CompanySettingsCubit()),
        BlocProvider(create: (_) => CompanyUsersCubit()),
      ],
      child: _AppShellView(appMode: appMode),
    );
  }

  NetworkStatusCubit _createNetworkStatusCubit(AppMode appMode) {
    final cubit = NetworkStatusCubit();

    if (appMode.isLive) {
      cubit.startWatching();
    }

    return cubit;
  }

  CurrentContextCubit _createCurrentContextCubit(AppMode appMode) {
    final cubit = CurrentContextCubit();

    if (appMode.isLive) {
      cubit.loadCurrentContext();
    }

    return cubit;
  }
}

class _AppShellView extends StatelessWidget {
  const _AppShellView({required this.appMode});

  final AppMode appMode;

  @override
  Widget build(BuildContext context) {
    if (appMode.isDemo) {
      return const _DemoAppShellView();
    }

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
      child: const _LiveAppShellView(),
    );
  }
}

class _LiveAppShellView extends StatelessWidget {
  const _LiveAppShellView();

  @override
  Widget build(BuildContext context) {
    return const GlobalOfflineBanner(
      child: UserContextRealtimeSyncScope(
        child: CurrentContextGate(
          child: CompanyRealtimeSyncScope(child: _ResponsiveShellContent()),
        ),
      ),
    );
  }
}

class _DemoAppShellView extends StatelessWidget {
  const _DemoAppShellView();

  @override
  Widget build(BuildContext context) {
    return const _ResponsiveShellContent();
  }
}

class _ResponsiveShellContent extends StatelessWidget {
  const _ResponsiveShellContent();

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: MobileShell(),
      tablet: TabletShell(),
      desktop: DesktopShell(),
    );
  }
}
