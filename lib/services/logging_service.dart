import 'package:flutter/foundation.dart';

class LoggingService {
  void log(String message) {
    if (kDebugMode) {
      print('[SSTP VPN] $message');
    }
  }

  void logError(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[SSTP VPN ERROR] $message');
      if (error != null) {
        print('Error: $error');
      }
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }
}
