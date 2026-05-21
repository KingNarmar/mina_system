import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      _debugRealtime('No active profile. Stopping user context sync.');
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

    _debugRealtime('Starting user context sync for profile_id=$profileId');

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
      _debugRealtime('User context sync status: $status');

      if (error != null) {
        _debugRealtime('User context sync error: $error');
      }
    });
  }

  void _handleUserContextEvent(PostgresChangePayload payload) {
    _debugRealtime(
      'USER CONTEXT EVENT => event=${payload.eventType}, '
      'new=${payload.newRecord}, old=${payload.oldRecord}',
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
      final oldState = context.read<CurrentContextCubit>().state;

      String? oldCompanyId;
      String? oldRole;
      int? oldCompaniesCount;

      if (oldState is CurrentContextLoaded) {
        oldCompanyId = oldState.currentCompany?.id;
        oldRole = oldState.currentCompany?.role;
        oldCompaniesCount = oldState.companies.length;
      }

      _debugRealtime(
        'Refreshing CurrentContext from user event. '
        'oldCompanyId=$oldCompanyId, oldRole=$oldRole, '
        'oldCompaniesCount=$oldCompaniesCount',
      );

      await context.read<CurrentContextCubit>().refreshCurrentContextSilently();

      if (!mounted) {
        return;
      }

      final newState = context.read<CurrentContextCubit>().state;

      if (newState is CurrentContextLoaded) {
        _debugRealtime(
          'CurrentContext refreshed from user event. '
          'newCompanyId=${newState.currentCompany?.id}, '
          'newRole=${newState.currentCompany?.role}, '
          'newCompaniesCount=${newState.companies.length}',
        );
      }
    } catch (error, stackTrace) {
      _debugRealtime('User context refresh error: $error');
      _debugRealtime('User context refresh stackTrace: $stackTrace');
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
      _debugRealtime('Stopping user context sync.');
      await _supabase.removeChannel(channel);
    } catch (error, stackTrace) {
      _debugRealtime('Stop user context sync error: $error');
      _debugRealtime('Stop user context sync stackTrace: $stackTrace');
    }
  }

  void _debugRealtime(String message) {
    if (!kDebugMode) {
      return;
    }

    debugPrint('[MinaUserContextRealtime] $message');
  }

  @override
  void dispose() {
    unawaited(_stopRealtimeSync());
    super.dispose();
  }
}
