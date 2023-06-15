import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final StreamController<ConnectivityResult> _connectivityController = StreamController<ConnectivityResult>();
  Stream<ConnectivityResult> get connectivityStream => _connectivityController.stream;

  ConnectivityService() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _connectivityController.add(result);
    });
  }

  void dispose() {
    _connectivityController.close();
  }
}
