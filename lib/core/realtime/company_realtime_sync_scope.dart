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
import 'package:mina_system/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:mina_system/features/transactions/presentation/cubit/transactions_state.dart';
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

  RealtimeChannel? _channel;

  Timer? _transactionsRefreshTimer;
  Timer? _companyMembersRefreshTimer;
  Timer? _currentContextRefreshTimer;

  String? _activeCompanyId;

  bool _hasPendingTransactionsRefresh = false;
  bool _hasPendingCompanyUsersRefresh = false;
  bool _hasPendingCurrentContextRefresh = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncWithCompanyId(context.currentCompanyId);
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

  Future<void> _refreshTransactions() async {
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

      if (!mounted) {
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

  bool _shouldDeferTransactionsRefresh(TransactionsState state) {
    return state.isTransactionFormOpen || state.isSubmitting;
  }

  bool _shouldDeferCompanyUsersRefresh(CompanyUsersState state) {
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

  Future<void> _stopRealtimeSync() async {
    _transactionsRefreshTimer?.cancel();
    _transactionsRefreshTimer = null;

    _companyMembersRefreshTimer?.cancel();
    _companyMembersRefreshTimer = null;

    _currentContextRefreshTimer?.cancel();
    _currentContextRefreshTimer = null;

    _hasPendingTransactionsRefresh = false;
    _hasPendingCompanyUsersRefresh = false;
    _hasPendingCurrentContextRefresh = false;

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
    unawaited(_stopRealtimeSync());
    super.dispose();
  }
}
