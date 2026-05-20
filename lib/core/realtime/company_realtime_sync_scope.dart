import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  String? _activeCompanyId;
  bool _hasPendingTransactionsRefresh = false;

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
      ],
      child: widget.child,
    );
  }

  void _syncWithCompanyId(String? companyId) {
    final cleanCompanyId = companyId?.trim();

    if (cleanCompanyId == null || cleanCompanyId.isEmpty) {
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

    final channel = _supabase.channel(
      'company-transactions-sync:$companyId:${DateTime.now().millisecondsSinceEpoch}',
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
      callback: (_) => _scheduleTransactionsRefresh(),
    );

    _channel = channel;

    channel.subscribe((status, [error]) {
      if (!kDebugMode) {
        return;
      }

      debugPrint('Transactions realtime sync status: $status');

      if (error != null) {
        debugPrint('Transactions realtime sync error: $error');
      }
    });
  }

  void _scheduleTransactionsRefresh() {
    _transactionsRefreshTimer?.cancel();

    _transactionsRefreshTimer = Timer(_refreshDebounceDuration, () {
      unawaited(_refreshTransactions());
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
      _hasPendingTransactionsRefresh = true;
      return;
    }

    try {
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
      if (kDebugMode) {
        debugPrint('Transactions realtime refresh error: $error');
        debugPrint('Transactions realtime refresh stackTrace: $stackTrace');
      }
    }
  }

  bool _shouldDeferTransactionsRefresh(TransactionsState state) {
    return state.isTransactionFormOpen || state.isSubmitting;
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

  Future<void> _stopRealtimeSync() async {
    _transactionsRefreshTimer?.cancel();
    _transactionsRefreshTimer = null;
    _hasPendingTransactionsRefresh = false;

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
        debugPrint('Stop transactions realtime sync error: $error');
        debugPrint('Stop transactions realtime sync stackTrace: $stackTrace');
      }
    }
  }

  @override
  void dispose() {
    unawaited(_stopRealtimeSync());
    super.dispose();
  }
}
