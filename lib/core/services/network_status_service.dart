import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:mina_system/core/config/app_environment.dart';

enum NetworkConnectionStatus { online, offline }

class NetworkStatusSnapshot {
  const NetworkStatusSnapshot({
    required this.status,
    required this.connectionTypes,
  });

  factory NetworkStatusSnapshot.fromConnectivityResults(
    List<ConnectivityResult> results,
  ) {
    final hasNoConnection =
        results.isEmpty || results.contains(ConnectivityResult.none);

    return NetworkStatusSnapshot(
      status: hasNoConnection
          ? NetworkConnectionStatus.offline
          : NetworkConnectionStatus.online,
      connectionTypes: List.unmodifiable(results),
    );
  }

  factory NetworkStatusSnapshot.online() {
    return const NetworkStatusSnapshot(
      status: NetworkConnectionStatus.online,
      connectionTypes: [],
    );
  }

  factory NetworkStatusSnapshot.offline() {
    return const NetworkStatusSnapshot(
      status: NetworkConnectionStatus.offline,
      connectionTypes: [ConnectivityResult.none],
    );
  }

  final NetworkConnectionStatus status;
  final List<ConnectivityResult> connectionTypes;

  bool get isOnline => status == NetworkConnectionStatus.online;

  bool get isOffline => status == NetworkConnectionStatus.offline;
}

class NetworkUnavailableException implements Exception {
  const NetworkUnavailableException({
    this.message =
        'No internet connection. Please check your network and try again.',
  });

  final String message;

  @override
  String toString() => message;
}

class NetworkStatusService {
  NetworkStatusService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Future<NetworkStatusSnapshot> getCurrentStatus() async {
    if (_shouldUseDevelopmentOnlineFallback) {
      return NetworkStatusSnapshot.online();
    }

    try {
      final results = await _connectivity.checkConnectivity();

      return NetworkStatusSnapshot.fromConnectivityResults(results);
    } catch (_) {
      if (_shouldUseDevelopmentOnlineFallback) {
        return NetworkStatusSnapshot.online();
      }

      return NetworkStatusSnapshot.offline();
    }
  }

  Stream<NetworkStatusSnapshot> watchStatus() async* {
    yield await getCurrentStatus();

    if (_shouldUseDevelopmentOnlineFallback) {
      return;
    }

    yield* _connectivity.onConnectivityChanged.map(
      NetworkStatusSnapshot.fromConnectivityResults,
    );
  }

  Future<bool> get isOnline async {
    final status = await getCurrentStatus();

    return status.isOnline;
  }

  Future<bool> get isOffline async {
    final status = await getCurrentStatus();

    return status.isOffline;
  }

  Future<void> ensureOnline() async {
    final status = await getCurrentStatus();

    if (status.isOffline) {
      throw const NetworkUnavailableException();
    }
  }

  bool get _shouldUseDevelopmentOnlineFallback {
    return kDebugMode &&
        AppEnvironment.isDevelopment &&
        !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.windows;
  }
}
