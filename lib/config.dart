import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  static String? _customServerUrl;

  // The local Wi-Fi IP of the host machine running the backend server
  static const String hostIp = '192.168.1.3';

  static String get defaultServerUrl {
    if (kIsWeb) {
      try {
        final origin = Uri.base.origin;
        if (origin.isNotEmpty && origin != 'null') {
          return origin;
        }
      } catch (_) {}
      return 'http://$hostIp:3000';
    }
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // Physical phone or mobile device on the same Wi-Fi
        return 'http://$hostIp:3000';
      }
    } catch (_) {}
    // Windows desktop, macOS, Linux
    return 'http://localhost:3000';
  }

  static String get serverUrl {
    if (kIsWeb) {
      try {
        final queryServer = Uri.base.queryParameters['server'];
        if (queryServer != null && queryServer.trim().isNotEmpty) {
          String s = queryServer.trim();
          if (!s.startsWith('http://') && !s.startsWith('https://')) {
            s = 'http://$s';
          }
          return s;
        }
      } catch (_) {}
    }
    return _customServerUrl ?? defaultServerUrl;
  }

  static set serverUrl(String url) {
    String trimmed = url.trim();
    if (trimmed.isNotEmpty) {
      if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
        trimmed = 'http://$trimmed';
      }
      _customServerUrl = trimmed;
    }
  }

  /// Generates a shareable URL that works globally when hosted or tunneled
  static String getInviteLink(String roomCode) {
    if (kIsWeb) {
      try {
        final origin = Uri.base.origin;
        if (origin.isNotEmpty && origin != 'null') {
          return '$origin/?room=$roomCode';
        }
      } catch (_) {}
    }
    return '$serverUrl/?room=$roomCode';
  }
}

