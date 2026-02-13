import '../utils/import.dart';

class NetworkService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = true.obs;

  Future<NetworkService> init() async {
    _connectivity.onConnectivityChanged.listen(_onStatusChange);
    return this;
  }

  void _onStatusChange(List<ConnectivityResult> results) {
    isConnected.value = !results.contains(ConnectivityResult.none);
  }
}
