import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/realtime/realtime_diagnostics.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_cubit.dart';
import 'package:mina_system/features/current_context/presentation/cubit/current_context_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserContextRealtimeSyncScope extends StatefulWidget {
  const UserContextRealtimeSyncScope({super.key, required this.child});

  final Widget child;

  @override
  State<UserContextRealtimeSyncScope> createState() =>
      _UserContextRealtimeSyncScopeState();
}

class _UserContextRealtimeSyncScopeState
    extends State<UserContextRealtimeSyncScope> {
  static const Duration _refreshDebounceDuration = Duration(milliseconds: 700);

  final SupabaseClient _supabase = Supabase.instance.client;

  RealtimeChannel? _channel;
  Timer? _currentContextRefreshTimer;

  String? _activeProfileId;
  bool _isRefreshingCurrentContext = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final state = context.read<CurrentContextCubit>().state;

    if (state is CurrentContextLoaded) {
      _syncWithProfileId(state.profile.id);
      return;
    }

    _syncWithProfileId(null);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CurrentContextCubit, CurrentContextState>(
      listenWhen: (previous, current) {
        final previousProfileId = _profileIdFromState(previous);
        final currentProfileId = _profileIdFromState(current);

        return previousProfileId != currentProfileId;
      },
      listener: (context, state) {
        _syncWithProfileId(_profileIdFromState(state));
      },
      child: widget.child,
    );
  }

  String? _profileIdFromState(CurrentContextState state) {
    if (state is CurrentContextLoaded) {
      return state.profile.id;
    }

    return null;
  }

  void _syncWithProfileId(String? profileId) {
    final cleanProfileId = profileId?.trim();

    if (cleanProfileId == null || cleanProfileId.isEmpty) {
      RealtimeDiagnostics.write(
        scope: RealtimeDiagnosticScope.userContext,
        area: RealtimeDiagnosticArea.sync,
        action: RealtimeDiagnosticAction.unavailable,
      );
      unawaited(_stopRealtimeSync());
      return;
    }

    if (_activeProfileId == cleanProfileId && _channel != null) {
      return;
    }

    unawaited(_startRealtimeSync(cleanProfileId));
  }

  Future<void> _startRealtimeSync(String profileId) async {
    await _stopRealtimeSync();

    if (!mounted) {
      return;
    }

    _activeProfileId = profileId;

    RealtimeDiagnostics.write(
      scope: RealtimeDiagnosticScope.userContext,
      area: RealtimeDiagnosticArea.sync,
      action: RealtimeDiagnosticAction.starting,
    );

    final channel = _supabase.channel(
      'user-context-sync:$profileId:${DateTime.now().millisecondsSinceEpoch}',
    );

    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'user_context_events',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'profile_id',
        value: profileId,
      ),
      callback: _handleUserContextEvent,
    );

    _channel = channel;

    channel.subscribe((status, [error]) {
      RealtimeDiagnostics.write(
        scope: RealtimeDiagnosticScope.userContext,
        area: RealtimeDiagnosticArea.subscription,
        action: RealtimeDiagnosticAction.statusChanged,
        status: status,
      );

      if (error != null) {
        RealtimeDiagnostics.write(
          scope: RealtimeDiagnosticScope.userContext,
          area: RealtimeDiagnosticArea.subscription,
          action: RealtimeDiagnosticAction.subscriptionFailed,
        );
      }
    });
  }

  void _handleUserContextEvent(PostgresChangePayload payload) {
    RealtimeDiagnostics.write(
      scope: RealtimeDiagnosticScope.userContext,
      area: RealtimeDiagnosticArea.currentContext,
      action: RealtimeDiagnosticAction.eventReceived,
      eventType: payload.eventType,
    );

    _scheduleCurrentContextRefresh();
  }

  void _scheduleCurrentContextRefresh() {
    _currentContextRefreshTimer?.cancel();

    _currentContextRefreshTimer = Timer(_refreshDebounceDuration, () {
      unawaited(_refreshCurrentContext());
    });
  }

  Future<void> _refreshCurrentContext() async {
    if (!mounted || _isRefreshingCurrentContext) {
      return;
    }

    _isRefreshingCurrentContext = true;

    try {
      RealtimeDiagnostics.write(
        scope: RealtimeDiagnosticScope.userContext,
        area: RealtimeDiagnosticArea.currentContext,
        action: RealtimeDiagnosticAction.refreshStarted,
      );

      await context.read<CurrentContextCubit>().refreshCurrentContextSilently();

      if (!mounted) {
        return;
      }

      RealtimeDiagnostics.write(
        scope: RealtimeDiagnosticScope.userContext,
        area: RealtimeDiagnosticArea.currentContext,
        action: RealtimeDiagnosticAction.refreshCompleted,
      );
    } catch (_) {
      RealtimeDiagnostics.write(
        scope: RealtimeDiagnosticScope.userContext,
        area: RealtimeDiagnosticArea.currentContext,
        action: RealtimeDiagnosticAction.refreshFailed,
      );
    } finally {
      _isRefreshingCurrentContext = false;
    }
  }

  Future<void> _stopRealtimeSync() async {
    _currentContextRefreshTimer?.cancel();
    _currentContextRefreshTimer = null;

    _isRefreshingCurrentContext = false;

    final channel = _channel;
    _channel = null;
    _activeProfileId = null;

    if (channel == null) {
      return;
    }

    try {
      RealtimeDiagnostics.write(
        scope: RealtimeDiagnosticScope.userContext,
        area: RealtimeDiagnosticArea.sync,
        action: RealtimeDiagnosticAction.stopping,
      );
      await _supabase.removeChannel(channel);
    } catch (_) {
      RealtimeDiagnostics.write(
        scope: RealtimeDiagnosticScope.userContext,
        area: RealtimeDiagnosticArea.sync,
        action: RealtimeDiagnosticAction.refreshFailed,
      );
    }
  }

  @override
  void dispose() {
    unawaited(_stopRealtimeSync());
    super.dispose();
  }
}
