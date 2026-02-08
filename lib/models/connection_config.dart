import 'vpn_server.dart';

class ConnectionConfig {
  final VpnServer server;
  final Duration timeout;
  final bool autoReconnect;

  ConnectionConfig({
    required this.server,
    this.timeout = const Duration(seconds: 30),
    this.autoReconnect = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'server': server.toJson(),
      'timeout': timeout.inSeconds,
      'autoReconnect': autoReconnect,
    };
  }

  factory ConnectionConfig.fromJson(Map<String, dynamic> json) {
    return ConnectionConfig(
      server: VpnServer.fromJson(json['server']),
      timeout: Duration(seconds: json['timeout'] ?? 30),
      autoReconnect: json['autoReconnect'] ?? false,
    );
  }
}
