import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// API base URL — must match the Laravel server (`client/.env` uses the same host).
///
/// - Web / Windows desktop: `http://127.0.0.1:8000/api`
/// - Android emulator: `http://10.0.2.2:8000/api` (host loopback alias)
/// - Physical device on LAN: set [lanHost] to your PC's local IP
class ApiConfig {
  /// Set to your PC LAN IP when testing on a physical phone, e.g. `192.168.1.100`.
  static const String? lanHost = null;

  static String get baseUrl {
    if (lanHost != null && lanHost!.isNotEmpty) {
      return 'http://$lanHost:8000/api';
    }

    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    }

    return 'http://127.0.0.1:8000/api';
  }
}
