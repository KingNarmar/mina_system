import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mina_system/core/services/network_status_service.dart';
import 'package:mina_system/core/utils/app_error_message.dart';

import 'network_status_state.dart';

class NetworkStatusCubit extends Cubit<NetworkStatusState> {
  NetworkStatusCubit({NetworkStatusService? service})
    : _service = service ?? NetworkStatusService(),
      super(const NetworkStatusInitial());

  final NetworkStatusService _service;

  StreamSubscription<NetworkStatusSnapshot>? _statusSubscription;
  Timer? _pollingTimer;

  Future<void> startWatching() async {
    await _statusSubscription?.cancel();
    _pollingTimer?.cancel();

    if (_shouldUsePolling) {
      await refresh();
      _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        refresh();
      });
      return;
    }

    try {
      _statusSubscription = _service.watchStatus().listen(
        _emitSnapshot,
        onError: (Object error, StackTrace stackTrace) {
          if (kDebugMode) {
            debugPrint('NetworkStatus error: $error');
            debugPrint('NetworkStatus stackTrace: $stackTrace');
          }

          emit(
            NetworkStatusFailure(
              AppErrorMessage.networkOnly(
                error,
                fallback: 'Unable to check network connection status.',
              ),
            ),
          );
        },
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('NetworkStatus startWatching error: $error');
        debugPrint('NetworkStatus startWatching stackTrace: $stackTrace');
      }

      emit(
        NetworkStatusFailure(
          AppErrorMessage.networkOnly(
            error,
            fallback: 'Unable to check network connection status.',
          ),
        ),
      );
    }
  }

  Future<void> refresh() async {
    try {
      final snapshot = await _service.getCurrentStatus();

      _emitSnapshot(snapshot);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('NetworkStatus refresh error: $error');
        debugPrint('NetworkStatus refresh stackTrace: $stackTrace');
      }

      emit(
        NetworkStatusFailure(
          AppErrorMessage.networkOnly(
            error,
            fallback: 'Unable to refresh network connection status.',
          ),
        ),
      );
    }
  }

  bool get _shouldUsePolling {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  }

  void _emitSnapshot(NetworkStatusSnapshot snapshot) {
    if (snapshot.isOffline) {
      emit(NetworkStatusOffline(snapshot));
      return;
    }

    emit(NetworkStatusOnline(snapshot));
  }

  @override
  Future<void> close() async {
    await _statusSubscription?.cancel();
    _pollingTimer?.cancel();

    return super.close();
  }
}
