import 'package:mina_system/core/services/network_status_service.dart';

abstract class NetworkStatusState {
  const NetworkStatusState();
}

class NetworkStatusInitial extends NetworkStatusState {
  const NetworkStatusInitial();
}

class NetworkStatusOnline extends NetworkStatusState {
  const NetworkStatusOnline(this.snapshot);

  final NetworkStatusSnapshot snapshot;
}

class NetworkStatusOffline extends NetworkStatusState {
  const NetworkStatusOffline(this.snapshot);

  final NetworkStatusSnapshot snapshot;
}

class NetworkStatusFailure extends NetworkStatusState {
  const NetworkStatusFailure(this.message);

  final String message;
}
