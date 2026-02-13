import 'dart:async';

import '../utils/import.dart';

class AppLoadingService extends GetxService {
  int _activeCalls = 0;

  final StreamController<bool> _streamController =
      StreamController<bool>.broadcast();

  Stream<bool> get stream => _streamController.stream;

  void startLoading() {
    _activeCalls++;
    _emitLoading();
  }

  void stopLoading() {
    if (_activeCalls > 0) {
      _activeCalls--;
      _emitLoading();
    }
  }

  void _emitLoading() {
    _streamController.add(_activeCalls > 0);
  }

  @override
  void onClose() {
    _streamController.close();
    super.onClose();
  }
}
