import 'package:flutter/services.dart';
import '../models/vpn_status.dart';
import '../models/vpn_server.dart';
import 'logging_service.dart';

class VpnService {
  static const MethodChannel _channel = MethodChannel('com.alihusains.sstp_vpn/vpn');
  static const EventChannel _statusChannel = EventChannel('com.alihusains.sstp_vpn/status');
  final LoggingService _logger = LoggingService();

  Stream<VpnStatus>? _statusStream;

  Stream<VpnStatus> get statusStream {
    _statusStream ??= _statusChannel.receiveBroadcastStream().map((dynamic status) {
      return _parseStatus(status as String);
    });
    return _statusStream!;
  }

  Future<bool> connect(VpnServer server) async {
    try {
      _logger.log('Connecting to VPN: ${server.name} (${server.serverAddress})');
      
      final result = await _channel.invokeMethod('connect', {
        'serverAddress': server.serverAddress,
        'port': server.port,
        'username': server.username,
        'password': server.password,
      });
      
      _logger.log('VPN connection result: $result');
      return result == true;
    } on PlatformException catch (e) {
      _logger.log('Failed to connect VPN: ${e.message}');
      return false;
    } catch (e) {
      _logger.log('Unexpected error connecting VPN: $e');
      return false;
    }
  }

  Future<bool> disconnect() async {
    try {
      _logger.log('Disconnecting VPN');
      
      final result = await _channel.invokeMethod('disconnect');
      
      _logger.log('VPN disconnection result: $result');
      return result == true;
    } on PlatformException catch (e) {
      _logger.log('Failed to disconnect VPN: ${e.message}');
      return false;
    } catch (e) {
      _logger.log('Unexpected error disconnecting VPN: $e');
      return false;
    }
  }

  Future<VpnStatus> getStatus() async {
    try {
      final status = await _channel.invokeMethod('getStatus');
      return _parseStatus(status as String);
    } on PlatformException catch (e) {
      _logger.log('Failed to get VPN status: ${e.message}');
      return VpnStatus.error;
    } catch (e) {
      _logger.log('Unexpected error getting VPN status: $e');
      return VpnStatus.error;
    }
  }

  VpnStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'connected':
        return VpnStatus.connected;
      case 'connecting':
        return VpnStatus.connecting;
      case 'disconnecting':
        return VpnStatus.disconnecting;
      case 'error':
        return VpnStatus.error;
      default:
        return VpnStatus.disconnected;
    }
  }

  Future<bool> requestVpnPermission() async {
    try {
      final result = await _channel.invokeMethod('requestPermission');
      return result == true;
    } catch (e) {
      _logger.log('Error requesting VPN permission: $e');
      return false;
    }
  }
}
