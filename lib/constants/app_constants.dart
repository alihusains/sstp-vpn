import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'SSTP VPN';
  static const String appVersion = '1.0.0';
  
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color connectedColor = Color(0xFF4CAF50);
  static const Color disconnectedColor = Color(0xFF9E9E9E);
  static const Color errorColor = Color(0xFFF44336);
  static const Color connectingColor = Color(0xFFFF9800);
  
  static const int defaultPort = 443;
  static const Duration connectionTimeout = Duration(seconds: 30);
  
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double iconSize = 24.0;
  static const double largeIconSize = 64.0;
  
  static const EdgeInsets screenPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(vertical: 8.0);
}
