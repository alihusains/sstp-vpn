enum VpnStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error;

  String get displayName {
    switch (this) {
      case VpnStatus.disconnected:
        return 'Disconnected';
      case VpnStatus.connecting:
        return 'Connecting...';
      case VpnStatus.connected:
        return 'Connected';
      case VpnStatus.disconnecting:
        return 'Disconnecting...';
      case VpnStatus.error:
        return 'Error';
    }
  }

  bool get isConnected => this == VpnStatus.connected;
  bool get isDisconnected => this == VpnStatus.disconnected;
  bool get isTransitioning => this == VpnStatus.connecting || this == VpnStatus.disconnecting;
}
