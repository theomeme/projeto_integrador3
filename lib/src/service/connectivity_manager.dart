import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:projeto_integrador3/src/service/connectivity_service.dart';

class ConnectivityManager {
  static final ConnectivityManager _instance = ConnectivityManager._internal();
  factory ConnectivityManager() => _instance;

  ConnectivityManager._internal();

  final ConnectivityService _connectivityService = ConnectivityService();
  Stream<ConnectivityResult> get connectivityStream => _connectivityService.connectivityStream;

  void dispose() {
    _connectivityService.dispose();
  }
}
