import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_cubit.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_state.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_cubit.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_state.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_state.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_state.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_state.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompanyRealtimeSyncScope extends StatefulWidget {
  const CompanyRealtimeSyncScope({super.key, required this.child});

  final Widget child;

  @override
  State<CompanyRealtimeSyncScope> createState() =>
      _CompanyRealtimeSyncScopeState();
}

class _CompanyRealtimeSyncScopeState extends State<CompanyRealtimeSyncScope>
    with WidgetsBindingObserver {
  static const Duration _refreshDebounceDuration = Duration(milliseconds: 700);

  final SupabaseClient _supabase = Supabase.instance.client;

  RealtimeChannel? _channel;

  Timer? _transactionsRefreshTimer;
  Timer? _companyMembersRefreshTimer;
  Timer? _currentContextRefreshTimer;
  Timer? _workersRefreshTimer;
  Timer? _toolsRefreshTimer;
  Timer? _lookupsRefreshTimer;

  String? _activeCompanyId;

  bool _hasPendingTransactionsRefresh = false;
  bool _hasPendingCompanyUsersRefresh = false;
  bool _hasPendingCurrentContextRefresh = false;
  bool _hasPendingWorkersRefresh = false;
  bool _hasPendingToolsRefresh = false;
  bool _hasPendingLookupsRefresh = false;
  bool _isHandlingAppResume = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncWithCompanyId(context.currentCompanyId);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      unawaited(_handleAppResumed());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CurrentContextCubit, CurrentContextState>(
          listenWhen: (previous, current) {
            if (previous is CurrentContextLoaded &&
                current is CurrentContextLoaded) {
              return previous.currentCompany?.id != current.currentCompany?.id;
            }

            return previous.runtimeType != current.runtimeType ||
                current is CurrentContextLoaded;
          },
          listener: (context, state) {
            if (state is CurrentContextLoaded) {
              _syncWithCompanyId(state.currentCompany?.id);
              return;
            }

            _syncWithCompanyId(null);
          },
        ),
        BlocListener<TransactionsCubit, TransactionsState>(
          listenWhen: (previous, current) {
            if (!_hasPendingTransactionsRefresh) {
              return false;
            }

            return previous.isTransactionFormOpen !=
                    current.isTransactionFormOpen ||
                previous.isSubmitting != current.isSubmitting;
          },
          listener: (context, state) {
            _tryFlushPendingTransactionsRefresh(state);
          },
        ),
        BlocListener<CompanyUsersCubit, CompanyUsersState>(
          listenWhen: (previous, current) {
            if (!_hasPendingCompanyUsersRefresh &&
                !_hasPendingCurrentContextRefresh) {
              return false;
            }

            return previous.isSubmitting != current.isSubmitting;
          },
          listener: (context, state) {
            _tryFlushPendingCompanyMembersRefresh(state);
          },
        ),
        BlocListener<WorkersCubit, WorkersState>(
          listenWhen: (previous, current) {
            if (!_hasPendingWorkersRefresh) {
              return false;
            }

            return previous.isSubmitting != current.isSubmitting;
          },
          listener: (context, state) {
            _tryFlushPendingWorkersRefresh(state);
          },
        ),
        BlocListener<ToolsCubit, ToolsState>(
          listenWhen: (previous, current) {
            if (!_hasPendingToolsRefresh) {
              return false;
            }

            return previous.isSubmitting != current.isSubmitting;
          },
          listener: (context, state) {
            _tryFlushPendingToolsRefresh(state);
          },
        ),
        BlocListener<LookupsCubit, LookupsState>(
          listenWhen: (previous, current) {
            if (!_hasPendingLookupsRefresh) {
              return false;
            }

            return previous.isSubmitting != current.isSubmitting;
          },
          listener: (context, state) {
            _tryFlushPendingLookupsRefresh(state);
          },
        ),
      ],
      child: widget.child,
    );
  }

  void _syncWithCompanyId(String? companyId) {
    final cleanCompanyId = companyId?.trim();

    if (cleanCompanyId == null || cleanCompanyId.isEmpty) {
      _debugRealtime('No active company. Stopping company realtime sync.');
      unawaited(_stopRealtimeSync());
      return;
    }

    if (_activeCompanyId == cleanCompanyId && _channel != null) {
      return;
    }

    unawaited(_startRealtimeSync(cleanCompanyId));
  }

  Future<void> _handleAppResumed() async {
    if (_isHandlingAppResume || !mounted) {
      return;
    }

    final currentCompanyId = _activeCompanyId?.trim().isNotEmpty == true
        ? _activeCompanyId!.trim()
        : context.currentCompanyId?.trim();

    if (currentCompanyId == null || currentCompanyId.isEmpty) {
      return;
    }

    _isHandlingAppResume = true;

    try {
      _debugRealtime(
        'App resumed. Prioritizing transaction refresh and restarting realtime sync.',
      );

      await _refreshCurrentContext();

      if (!mounted) {
        return;
      }

      final refreshedCompanyId = context.currentCompanyId?.trim();
      final targetCompanyId = refreshedCompanyId != null &&
              refreshedCompanyId.isNotEmpty
          ? refreshedCompanyId
          : currentCompanyId;

      await _startRealtimeSync(targetCompanyId);

      if (!mounted) {
        return;
      }

      await _refreshTransactions();

      if (!mounted) {
        return;
      }

      await Future.wait([
        _refreshLookups(),
        _refreshCompanyUsers(),
        _refreshWorkers(refreshDashboard: false),
        _refreshTools(refreshDashboard: false),
      ]);
    } catch (error, stackTrace) {
      _debugRealtime('App resume realtime refresh error: $error');
      _debugRealtime('App resume realtime refresh stackTrace: $stackTrace');
    } finally {
      _isHandlingAppResume = false;
    }
  }

  Future<void> _startRealtimeSync(String companyId) async {
    await _stopRealtimeSync();

    if (!mounted) {
      return;
    }

    _activeCompanyId = companyId;

    _debugRealtime('Starting company realtime sync for company_id=$companyId');

    final channel = _supabase.channel(
      'company-realtime-sync:$companyId:${DateTime.now().millisecondsSinceEpoch}',
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'transactions',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'company_id',
        value: companyId,
      ),
      callback: (payload) {
        _debugRealtime(
          'TRANSACTIONS EVENT => event=${payload.eventType}, '
          'new=${payload.newRecord}, old=${payload.oldRecord}',
        );

        _scheduleTransactionsRefresh();
      },
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'company_members',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'company_id',
        value: companyId,
      ),
      callback: _handleCompanyMemberChange,
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'workers',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'company_id',
        value: companyId,
      ),
      callback: _handleWorkerChange,
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'tools',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'company_id',
        value: companyId,
      ),
      callback: _handleToolChange,
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'departments',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'company_id',
        value: companyId,
      ),
      callback: (payload) {
        _handleLookupChange(tableName: 'departments', payload: payload);
      },
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'job_titles',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'company_id',
        value: companyId,
      ),
      callback: (payload) {
        _handleLookupChange(tableName: 'job_titles', payload: payload);
      },
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'tool_units',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'company_id',
        value: companyId,
      ),
      callback: (payload) {
        _handleLookupChange(tableName: 'tool_units', payload: payload);
      },
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'tool_categories',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'company_id',
        value: companyId,
      ),
      callback: (payload) {
        _handleLookupChange(tableName: 'tool_categories', payload: payload);
      },
    );

    _channel = channel;

    channel.subscribe((status, [error]) {
      _debugRealtime('Company realtime sync status: $status');

      if (error != null) {
        _debugRealtime('Company realtime sync error: $error');
      }
    });
  }

  void _handleCompanyMemberChange(PostgresChangePayload payload) {
    _debugRealtime(
      'COMPANY MEMBERS EVENT => event=${payload.eventType}, '
      'new=${payload.newRecord}, old=${payload.oldRecord}',
    );

    _scheduleCompanyUsersRefresh();
    _scheduleCurrentContextRefresh();
  }

  void _handleWorkerChange(PostgresChangePayload payload) {
    _debugRealtime(
      'WORKERS EVENT => event=${payload.eventType}, '
      'new=${payload.newRecord}, old=${payload.oldRecord}',
    );

    _scheduleWorkersRefresh();
  }

  void _handleToolChange(PostgresChangePayload payload) {
    _debugRealtime(
      'TOOLS EVENT => event=${payload.eventType}, '
      'new=${payload.newRecord}, old=${payload.oldRecord}',
    );

    _scheduleToolsRefresh();
  }

  void _handleLookupChange({
    required String tableName,
    required PostgresChangePayload payload,
  }) {
    _debugRealtime(
      'LOOKUPS/$tableName EVENT => event=${payload.eventType}, '
      'new=${payload.newRecord}, old=${payload.oldRecord}',
    );

    _scheduleLookupsRefresh();
  }

  void _scheduleTransactionsRefresh() {
    _transactionsRefreshTimer?.cancel();

    _transactionsRefreshTimer = Timer(_refreshDebounceDuration, () {
      unawaited(_refreshTransactions());
    });
  }

  void _scheduleCompanyUsersRefresh() {
    _companyMembersRefreshTimer?.cancel();

    _companyMembersRefreshTimer = Timer(_refreshDebounceDuration, () {
      unawaited(_refreshCompanyUsers());
    });
  }

  void _scheduleCurrentContextRefresh() {
    _currentContextRefreshTimer?.cancel();

    _currentContextRefreshTimer = Timer(_refreshDebounceDuration, () {
      unawaited(_refreshCurrentContext());
    });
  }

  void _scheduleWorkersRefresh() {
    _workersRefreshTimer?.cancel();

    _workersRefreshTimer = Timer(_refreshDebounceDuration, () {
      unawaited(_refreshWorkers());
    });
  }

  void _scheduleToolsRefresh() {
    _toolsRefreshTimer?.cancel();

    _toolsRefreshTimer = Timer(_refreshDebounceDuration, () {
      unawaited(_refreshTools());
    });
  }

  void _scheduleLookupsRefresh() {
    _lookupsRefreshTimer?.cancel();

    _lookupsRefreshTimer = Timer(_refreshDebounceDuration, () {
      unawaited(_refreshLookups());
    });
  }

  Future<void> _refreshTransactions({bool refreshDashboard = true}) async {
    if (!mounted) {
      return;
    }

    final companyId = _activeCompanyId;

    if (companyId == null || companyId.trim().isEmpty) {
      return;
    }

    final transactionsCubit = context.read<TransactionsCubit>();
    final dashboardCubit = context.read<DashboardCubit>();

    if (_shouldDeferTransactionsRefresh(transactionsCubit.state)) {
      _debugRealtime('Transactions refresh deferred.');
      _hasPendingTransactionsRefresh = true;
      return;
    }

    try {
      _debugRealtime('Refreshing transactions silently.');

      await transactionsCubit.loadTransactions(
        companyId: companyId,
        showLoader: false,
      );

      if (!mounted || !refreshDashboard) {
        return;
      }

      await dashboardCubit.loadDashboardSummary(
        companyId: companyId,
        showLoader: false,
      );
    } catch (error, stackTrace) {
      _debugRealtime('Transactions realtime refresh error: $error');
      _debugRealtime('Transactions realtime refresh stackTrace: $stackTrace');
    }
  }

  Future<void> _refreshCompanyUsers() async {
    if (!mounted) {
      return;
    }

    final companyId = _activeCompanyId;

    if (companyId == null || companyId.trim().isEmpty) {
      return;
    }

    final companyUsersCubit = context.read<CompanyUsersCubit>();

    if (_shouldDeferCompanyUsersRefresh(companyUsersCubit.state)) {
      _debugRealtime('Company users refresh deferred.');
      _hasPendingCompanyUsersRefresh = true;
      return;
    }

    try {
      _debugRealtime('Refreshing company users silently.');

      await companyUsersCubit.loadCompanyUsers(
        companyId: companyId,
        showLoader: false,
      );
    } catch (error, stackTrace) {
      _debugRealtime('Company users realtime refresh error: $error');
      _debugRealtime('Company users realtime refresh stackTrace: $stackTrace');
    }
  }

  Future<void> _refreshCurrentContext() async {
    if (!mounted) {
      return;
    }

    final companyUsersCubit = context.read<CompanyUsersCubit>();

    if (_shouldDeferCompanyUsersRefresh(companyUsersCubit.state)) {
      _debugRealtime('CurrentContext refresh deferred.');
      _hasPendingCurrentContextRefresh = true;
      return;
    }

    try {
      final oldRole = context.currentUserRole;
      final oldCompanyId = context.currentCompanyId;

      _debugRealtime(
        'Refreshing CurrentContext silently. '
        'oldCompanyId=$oldCompanyId, oldRole=$oldRole',
      );

      await context.read<CurrentContextCubit>().refreshCurrentContextSilently();

      if (!mounted) {
        return;
      }

      _debugRealtime(
        'CurrentContext refreshed. '
        'newCompanyId=${context.currentCompanyId}, '
        'newRole=${context.currentUserRole}',
      );
    } catch (error, stackTrace) {
      _debugRealtime('Current context realtime refresh error: $error');
      _debugRealtime(
        'Current context realtime refresh stackTrace: $stackTrace',
      );
    }
  }

  Future<void> _refreshWorkers({bool refreshDashboard = true}) async {
    if (!mounted) {
      return;
    }

    final companyId = _activeCompanyId;

    if (companyId == null || companyId.trim().isEmpty) {
      return;
    }

    final workersCubit = context.read<WorkersCubit>();
    final dashboardCubit = context.read<DashboardCubit>();

    if (_shouldDeferWorkersRefresh(workersCubit.state)) {
      _debugRealtime('Workers refresh deferred.');
      _hasPendingWorkersRefresh = true;
      return;
    }

    try {
      _debugRealtime('Refreshing workers silently.');

      await workersCubit.loadWorkers(companyId: companyId, showLoader: false);

      if (!mounted || !refreshDashboard) {
        return;
      }

      await dashboardCubit.loadDashboardSummary(
        companyId: companyId,
        showLoader: false,
      );
    } catch (error, stackTrace) {
      _debugRealtime('Workers realtime refresh error: $error');
      _debugRealtime('Workers realtime refresh stackTrace: $stackTrace');
    }
  }

  Future<void> _refreshTools({bool refreshDashboard = true}) async {
    if (!mounted) {
      return;
    }

    final companyId = _activeCompanyId;

    if (companyId == null || companyId.trim().isEmpty) {
      return;
    }

    final toolsCubit = context.read<ToolsCubit>();
    final dashboardCubit = context.read<DashboardCubit>();

    if (_shouldDeferToolsRefresh(toolsCubit.state)) {
      _debugRealtime('Tools refresh deferred.');
      _hasPendingToolsRefresh = true;
      return;
    }

    try {
      _debugRealtime('Refreshing tools silently.');

      await toolsCubit.loadTools(companyId: companyId, showLoader: false);

      if (!mounted || !refreshDashboard) {
        return;
      }

      await dashboardCubit.loadDashboardSummary(
        companyId: companyId,
        showLoader: false,
      );
    } catch (error, stackTrace) {
      _debugRealtime('Tools realtime refresh error: $error');
      _debugRealtime('Tools realtime refresh stackTrace: $stackTrace');
    }
  }

  Future<void> _refreshLookups() async {
    if (!mounted) {
      return;
    }

    final companyId = _activeCompanyId;

    if (companyId == null || companyId.trim().isEmpty) {
      return;
    }

    final lookupsCubit = context.read<LookupsCubit>();

    if (_shouldDeferLookupsRefresh(lookupsCubit.state)) {
      _debugRealtime('Lookups refresh deferred.');
      _hasPendingLookupsRefresh = true;
      return;
    }

    try {
      _debugRealtime('Refreshing lookups silently.');

      await lookupsCubit.loadLookups(companyId: companyId, showLoader: false);
    } catch (error, stackTrace) {
      _debugRealtime('Lookups realtime refresh error: $error');
      _debugRealtime('Lookups realtime refresh stackTrace: $stackTrace');
    }
  }

  bool _shouldDeferTransactionsRefresh(TransactionsState state) {
    return state.isTransactionFormOpen || state.isSubmitting;
  }

  bool _shouldDeferCompanyUsersRefresh(CompanyUsersState state) {
    return state.isSubmitting;
  }

  bool _shouldDeferWorkersRefresh(WorkersState state) {
    return state.isSubmitting;
  }

  bool _shouldDeferToolsRefresh(ToolsState state) {
    return state.isSubmitting;
  }

  bool _shouldDeferLookupsRefresh(LookupsState state) {
    return state.isSubmitting;
  }

  void _tryFlushPendingTransactionsRefresh(TransactionsState state) {
    if (!_hasPendingTransactionsRefresh) {
      return;
    }

    if (_shouldDeferTransactionsRefresh(state)) {
      return;
    }

    _hasPendingTransactionsRefresh = false;
    _scheduleTransactionsRefresh();
  }

  void _tryFlushPendingCompanyMembersRefresh(CompanyUsersState state) {
    if (_shouldDeferCompanyUsersRefresh(state)) {
      return;
    }

    if (_hasPendingCompanyUsersRefresh) {
      _hasPendingCompanyUsersRefresh = false;
      _scheduleCompanyUsersRefresh();
    }

    if (_hasPendingCurrentContextRefresh) {
      _hasPendingCurrentContextRefresh = false;
      _scheduleCurrentContextRefresh();
    }
  }

  void _tryFlushPendingWorkersRefresh(WorkersState state) {
    if (!_hasPendingWorkersRefresh) {
      return;
    }

    if (_shouldDeferWorkersRefresh(state)) {
      return;
    }

    _hasPendingWorkersRefresh = false;
    _scheduleWorkersRefresh();
  }

  void _tryFlushPendingToolsRefresh(ToolsState state) {
    if (!_hasPendingToolsRefresh) {
      return;
    }

    if (_shouldDeferToolsRefresh(state)) {
      return;
    }

    _hasPendingToolsRefresh = false;
    _scheduleToolsRefresh();
  }

  void _tryFlushPendingLookupsRefresh(LookupsState state) {
    if (!_hasPendingLookupsRefresh) {
      return;
    }

    if (_shouldDeferLookupsRefresh(state)) {
      return;
    }

    _hasPendingLookupsRefresh = false;
    _scheduleLookupsRefresh();
  }

  Future<void> _stopRealtimeSync() async {
    _transactionsRefreshTimer?.cancel();
    _transactionsRefreshTimer = null;

    _companyMembersRefreshTimer?.cancel();
    _companyMembersRefreshTimer = null;

    _currentContextRefreshTimer?.cancel();
    _currentContextRefreshTimer = null;

    _workersRefreshTimer?.cancel();
    _workersRefreshTimer = null;

    _toolsRefreshTimer?.cancel();
    _toolsRefreshTimer = null;

    _lookupsRefreshTimer?.cancel();
    _lookupsRefreshTimer = null;

    _hasPendingTransactionsRefresh = false;
    _hasPendingCompanyUsersRefresh = false;
    _hasPendingCurrentContextRefresh = false;
    _hasPendingWorkersRefresh = false;
    _hasPendingToolsRefresh = false;
    _hasPendingLookupsRefresh = false;

    final channel = _channel;
    _channel = null;
    _activeCompanyId = null;

    if (channel == null) {
      return;
    }

    try {
      _debugRealtime('Stopping company realtime sync.');
      await _supabase.removeChannel(channel);
    } catch (error, stackTrace) {
      _debugRealtime('Stop company realtime sync error: $error');
      _debugRealtime('Stop company realtime sync stackTrace: $stackTrace');
    }
  }

  void _debugRealtime(String message) {
    if (!kDebugMode) {
      return;
    }

    debugPrint('[MinaRealtime] $message');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_stopRealtimeSync());
    super.dispose();
  }
}
