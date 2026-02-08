import 'package:sstp_flutter/sstp_flutter.dart';
import '../models/vpn_status.dart';
import '../models/vpn_server.dart';
import 'logging_service.dart';

class VpnService {
  final SstpFlutter _sstpFlutter = SstpFlutter();
  final LoggingService _logger = LoggingService();
  
  VpnStatus _currentStatus = VpnStatus.disconnected;
  final List<VoidCallback> _statusListeners = [];

  Stream<VpnStatus>? _statusStream;

  Stream<VpnStatus> get statusStream async* {
    yield _currentStatus;
    await for (final callback in Stream.fromIterable(_statusListeners)) {
      yield _currentStatus;
    }
  }

  void _notifyStatusListeners() {
    for (final callback in _statusListeners) {
      callback();
    }
  }
  
  Future<void> initialize() async {
    try {
      await _sstpFlutter.takePermission();
      
      _sstpFlutter.observeStates(
        onConnectedResult: () {
          _currentStatus = VpnStatus.connected;
          _logger.log('SSTP VPN connected successfully');
          _notifyStatusListeners();
        },
        onConnectingResult: () {
          _currentStatus = VpnStatus.connecting;
          _logger.log('SSTP VPN connecting...');
          _notifyStatusListeners();
        },
        onDisconnectedResult: () {
          _currentStatus = VpnStatus.disconnected;
          _logger.log('SSTP VPN disconnected');
          _notifyStatusListeners();
        },
        onError: () {
          _currentStatus = VpnStatus.error;
          _logger.log('SSTP VPN error occurred');
          _notifyStatusListeners();
        },
      );
    } catch (e) {
      _logger.log('Error initializing SSTP VPN: $e');
    }
  }

  Future<bool> connect(VpnServer server) async {
    try {
      _logger.log('Connecting to SSTP VPN: ${server.name} (${server.serverAddress})');
      
      final sstpServer = SSTPServer(
        host: server.serverAddress,
        port: server.port,
        username: server.username,
        password: server.password,
        androidConfiguration: SSTPAndroidConfiguration(
          verifyHostName: false,
          useTrustedCert: false,
          verifySSLCert: false,
          sslVersion: SSLVersions.TLSv1_2,
          showDisconnectOnNotification: true,
          notificationText: "SSTP VPN Connected",
        ),
        iosConfiguration: SSTPIOSConfiguration(
          useTrustedCert: false,
          verifySSLCert: false,
          sslVersion: SSLVersions.TLSv1_2,
        ),
      );
      
      await _sstpFlutter.connectVpn(sstpServer: sstpServer);
      return true;
    } catch (e) {
      _logger.log('Failed to connect SSTP VPN: $e');
      return false;
    }
  }

  Future<bool> disconnect() async {
    try {
      _logger.log('Disconnecting SSTP VPN');
      await _sstpFlutter.disconnect();
      return true;
    } catch (e) {
      _logger.log('Failed to disconnect SSTP VPN: $e');
      return false;
    }
  }

  Future<VpnStatus> getStatus() async {
    return _currentStatus;
  }

  Future<bool> requestVpnPermission() async {
    try {
      await _sstpFlutter.takePermission();
      return true;
    } catch (e) {
      _logger.log('Error requesting SSTP VPN permission: $e');
      return false;
    }
  }
}
