import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/features/company_settings/presentation/cubit/company_settings_cubit.dart';
import 'package:mina_system/features/company_users/presentation/cubit/company_users_cubit.dart';
import 'package:mina_system/features/current_context/presentation/extensions/current_context_extensions.dart';
import 'package:mina_system/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:mina_system/features/lookups/presentation/cubit/lookups_cubit.dart';
import 'package:mina_system/features/tools/presentation/cubit/tools_cubit.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/workers/presentation/cubit/workers_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompanyRealtimeSyncScope extends StatefulWidget {
  const CompanyRealtimeSyncScope({super.key, required this.child});

  final Widget child;

  @override
  State<CompanyRealtimeSyncScope> createState() =>
      _CompanyRealtimeSyncScopeState();
}

class _CompanyRealtimeSyncScopeState extends State<CompanyRealtimeSyncScope> {
  static const Duration _refreshDebounceDuration = Duration(milliseconds: 700);

  final SupabaseClient _supabase = Supabase.instance.client;
  final Map<_CompanyRealtimeRefreshGroup, Timer> _refreshTimers = {};

  RealtimeChannel? _channel;
  String? _activeCompanyId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final companyId = context.currentCompanyId;

    if (companyId == null || companyId.trim().isEmpty) {
      unawaited(_stopRealtimeSync());
      return;
    }

    if (_activeCompanyId == companyId && _channel != null) {
      return;
    }

    unawaited(_startRealtimeSync(companyId));
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  Future<void> _startRealtimeSync(String companyId) async {
    await _stopRealtimeSync();

    if (!mounted) {
      return;
    }

    _activeCompanyId = companyId;

    final channel = _supabase.channel(
      'company-wide-sync:$companyId:${DateTime.now().millisecondsSinceEpoch}',
    );

    _listenToCompanyTable(
      channel: channel,
      table: 'transactions',
      companyId: companyId,
      refreshGroup: _CompanyRealtimeRefreshGroup.transactions,
    );

    _listenToCompanyTable(
      channel: channel,
      table: 'workers',
      companyId: companyId,
      refreshGroup: _CompanyRealtimeRefreshGroup.workers,
    );

    _listenToCompanyTable(
      channel: channel,
      table: 'tools',
      companyId: companyId,
      refreshGroup: _CompanyRealtimeRefreshGroup.tools,
    );

    _listenToCompanyTable(
      channel: channel,
      table: 'departments',
      companyId: companyId,
      refreshGroup: _CompanyRealtimeRefreshGroup.lookups,
    );

    _listenToCompanyTable(
      channel: channel,
      table: 'job_titles',
      companyId: companyId,
      refreshGroup: _CompanyRealtimeRefreshGroup.lookups,
    );

    _listenToCompanyTable(
      channel: channel,
      table: 'tool_units',
      companyId: companyId,
      refreshGroup: _CompanyRealtimeRefreshGroup.lookups,
    );

    _listenToCompanyTable(
      channel: channel,
      table: 'tool_categories',
      companyId: companyId,
      refreshGroup: _CompanyRealtimeRefreshGroup.lookups,
    );

    _listenToCompanyTable(
      channel: channel,
      table: 'company_report_settings',
      companyId: companyId,
      refreshGroup: _CompanyRealtimeRefreshGroup.companySettings,
    );

    _listenToCompanyTable(
      channel: channel,
      table: 'company_document_templates',
      companyId: companyId,
      refreshGroup: _CompanyRealtimeRefreshGroup.companySettings,
    );

    _listenToCompanyTable(
      channel: channel,
      table: 'company_members',
      companyId: companyId,
      refreshGroup: _CompanyRealtimeRefreshGroup.companyUsers,
    );

    _listenToCompanyTable(
      channel: channel,
      table: 'company_invitations',
      companyId: companyId,
      refreshGroup: _CompanyRealtimeRefreshGroup.companyUsers,
    );

    _listenToCompanyRowTable(
      channel: channel,
      table: 'companies',
      companyId: companyId,
      refreshGroup: _CompanyRealtimeRefreshGroup.companySettings,
    );

    _channel = channel;

    channel.subscribe((status, [error]) {
      if (!kDebugMode) {
        return;
      }

      debugPrint('Company realtime sync status: $status');

      if (error != null) {
        debugPrint('Company realtime sync error: $error');
      }
    });
  }

  void _listenToCompanyTable({
    required RealtimeChannel channel,
    required String table,
    required String companyId,
    required _CompanyRealtimeRefreshGroup refreshGroup,
  }) {
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: table,
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'company_id',
        value: companyId,
      ),
      callback: (_) => _scheduleRefresh(refreshGroup),
    );
  }

  void _listenToCompanyRowTable({
    required RealtimeChannel channel,
    required String table,
    required String companyId,
    required _CompanyRealtimeRefreshGroup refreshGroup,
  }) {
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: table,
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'id',
        value: companyId,
      ),
      callback: (_) => _scheduleRefresh(refreshGroup),
    );
  }

  void _scheduleRefresh(_CompanyRealtimeRefreshGroup refreshGroup) {
    _refreshTimers[refreshGroup]?.cancel();

    _refreshTimers[refreshGroup] = Timer(_refreshDebounceDuration, () {
      unawaited(_refreshCompanyData(refreshGroup));
    });
  }

  Future<void> _refreshCompanyData(
    _CompanyRealtimeRefreshGroup refreshGroup,
  ) async {
    if (!mounted) {
      return;
    }

    final companyId = _activeCompanyId;

    if (companyId == null || companyId.trim().isEmpty) {
      return;
    }

    final transactionsCubit = context.read<TransactionsCubit>();
    final dashboardCubit = context.read<DashboardCubit>();
    final workersCubit = context.read<WorkersCubit>();
    final toolsCubit = context.read<ToolsCubit>();
    final lookupsCubit = context.read<LookupsCubit>();
    final companySettingsCubit = context.read<CompanySettingsCubit>();
    final companyUsersCubit = context.read<CompanyUsersCubit>();

    try {
      switch (refreshGroup) {
        case _CompanyRealtimeRefreshGroup.transactions:
          await transactionsCubit.loadTransactions(
            companyId: companyId,
            showLoader: false,
          );
          await dashboardCubit.loadDashboardSummary(
            companyId: companyId,
            showLoader: false,
          );
          break;

        case _CompanyRealtimeRefreshGroup.workers:
          await workersCubit.loadWorkers(
            companyId: companyId,
            showLoader: false,
          );
          await dashboardCubit.loadDashboardSummary(
            companyId: companyId,
            showLoader: false,
          );
          break;

        case _CompanyRealtimeRefreshGroup.tools:
          await toolsCubit.loadTools(companyId: companyId, showLoader: false);
          await dashboardCubit.loadDashboardSummary(
            companyId: companyId,
            showLoader: false,
          );
          break;

        case _CompanyRealtimeRefreshGroup.lookups:
          await lookupsCubit.loadLookups(
            companyId: companyId,
            showLoader: false,
          );
          await workersCubit.loadWorkers(
            companyId: companyId,
            showLoader: false,
          );
          await toolsCubit.loadTools(companyId: companyId, showLoader: false);
          break;

        case _CompanyRealtimeRefreshGroup.companySettings:
          await companySettingsCubit.loadCompanyProfile(
            companyId: companyId,
            showLoader: false,
          );
          break;

        case _CompanyRealtimeRefreshGroup.companyUsers:
          await companyUsersCubit.loadCompanyUsers(
            companyId: companyId,
            showLoader: false,
          );
          break;
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Company realtime refresh error: $error');
        debugPrint('Company realtime refresh stackTrace: $stackTrace');
      }
    }
  }

  Future<void> _stopRealtimeSync() async {
    for (final timer in _refreshTimers.values) {
      timer.cancel();
    }

    _refreshTimers.clear();

    final channel = _channel;
    _channel = null;
    _activeCompanyId = null;

    if (channel == null) {
      return;
    }

    try {
      await _supabase.removeChannel(channel);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Stop company realtime sync error: $error');
        debugPrint('Stop company realtime sync stackTrace: $stackTrace');
      }
    }
  }

  @override
  void dispose() {
    unawaited(_stopRealtimeSync());
    super.dispose();
  }
}

enum _CompanyRealtimeRefreshGroup {
  transactions,
  workers,
  tools,
  lookups,
  companySettings,
  companyUsers,
}
