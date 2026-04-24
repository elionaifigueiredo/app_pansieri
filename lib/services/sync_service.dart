import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'api_service.dart';
import 'db_service.dart';

class SyncService {
  static Timer? _timer;

  static void startAutoSync() {
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      await syncNow();
    });
  }

  static Future<void> syncNow() async {
    final conn = await Connectivity().checkConnectivity();

    if (conn == ConnectivityResult.none) {
      return; // offline
    }

    try {
      final apiData = await ApiService.getAdvogados();

      await DBService.salvarLocal(apiData);

    } catch (e) {
      print("Erro sync: $e");
    }
  }

  static void stop() {
    _timer?.cancel();
  }
}