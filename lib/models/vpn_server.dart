class VpnServer {
  final String id;
  final String name;
  final String serverAddress;
  final int port;
  final String username;
  final String password;

  VpnServer({
    required this.id,
    required this.name,
    required this.serverAddress,
    required this.port,
    required this.username,
    required this.password,
  });

  factory VpnServer.fromJson(Map<String, dynamic> json) {
    return VpnServer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      serverAddress: json['serverAddress'] ?? '',
      port: json['port'] ?? 443,
      username: json['username'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'serverAddress': serverAddress,
      'port': port,
      'username': username,
      'password': password,
    };
  }

  VpnServer copyWith({
    String? id,
    String? name,
    String? serverAddress,
    int? port,
    String? username,
    String? password,
  }) {
    return VpnServer(
      id: id ?? this.id,
      name: name ?? this.name,
      serverAddress: serverAddress ?? this.serverAddress,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
}
