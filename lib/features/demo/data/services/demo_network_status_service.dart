import 'package:mina_system/core/services/network_status_service.dart';

class DemoNetworkStatusService extends NetworkStatusService {
  @override
  Future<NetworkStatusSnapshot> getCurrentStatus() async {
    return NetworkStatusSnapshot.online();
  }

  @override
  Stream<NetworkStatusSnapshot> watchStatus() async* {
    yield NetworkStatusSnapshot.online();
  }

  @override
  Future<void> ensureOnline() async {
    return;
  }
}
