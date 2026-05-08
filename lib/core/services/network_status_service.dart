import 'package:connectivity_plus/connectivity_plus.dart';

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
    try {
      final results = await _connectivity.checkConnectivity();

      return NetworkStatusSnapshot.fromConnectivityResults(results);
    } catch (_) {
      return NetworkStatusSnapshot.offline();
    }
  }

  Stream<NetworkStatusSnapshot> watchStatus() async* {
    yield await getCurrentStatus();

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
}
