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
import 'package:mina_system/features/demo/data/repo/demo_dashboard_repo.dart';
import 'package:mina_system/features/demo/data/services/demo_seed_service.dart';
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
        BlocProvider(create: (_) => _createDashboardCubit(appMode)),
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
      return cubit;
    }

    cubit.loadDemoCurrentContext();
    return cubit;
  }

  DashboardCubit _createDashboardCubit(AppMode appMode) {
    if (appMode.isDemo) {
      return DashboardCubit(dashboardRepo: DemoDashboardRepo());
    }

    return DashboardCubit();
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

class _DemoAppShellView extends StatefulWidget {
  const _DemoAppShellView();

  @override
  State<_DemoAppShellView> createState() => _DemoAppShellViewState();
}

class _DemoAppShellViewState extends State<_DemoAppShellView> {
  late final Future<void> _demoInitializationFuture;

  @override
  void initState() {
    super.initState();

    _demoInitializationFuture = _initializeDemoWorkspace();
  }

  Future<void> _initializeDemoWorkspace() async {
    await const DemoSeedService().initializeIfNeeded();

    if (!mounted) {
      return;
    }

    await context.read<DashboardCubit>().loadDashboardSummary(
      companyId: DemoSeedService.demoCompanyId,
      showLoader: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _demoInitializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _DemoInitializationLoadingView();
        }

        if (snapshot.hasError) {
          return _DemoInitializationFailureView(error: snapshot.error);
        }

        return const _ResponsiveShellContent();
      },
    );
  }
}

class _DemoInitializationLoadingView extends StatelessWidget {
  const _DemoInitializationLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _DemoInitializationFailureView extends StatelessWidget {
  const _DemoInitializationFailureView({required this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Unable to initialize demo data.\n$error',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
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