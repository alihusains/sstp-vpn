import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/vpn_status.dart';
import '../models/vpn_server.dart';
import '../services/vpn_service.dart';
import '../services/storage_service.dart';
import '../services/logging_service.dart';

class VpnProvider with ChangeNotifier {
  final VpnService _vpnService = VpnService();
  final StorageService _storageService = StorageService();
  final LoggingService _logger = LoggingService();
  
  VpnStatus _status = VpnStatus.disconnected;
  String? _errorMessage;
  DateTime? _connectionStartTime;
  Duration _connectionDuration = Duration.zero;
  bool _autoReconnect = false;

  VpnStatus get status => _status;
  String? get errorMessage => _errorMessage;
  DateTime? get connectionStartTime => _connectionStartTime;
  Duration get connectionDuration => _connectionDuration;
  bool get autoReconnect => _autoReconnect;
  bool get isConnected => _status == VpnStatus.connected;
  bool get isConnecting => _status == VpnStatus.connecting;
  bool get isDisconnected => _status == VpnStatus.disconnected;

  VpnProvider() {
    _init();
  }

  Future<void> _init() async {
    _autoReconnect = await _storageService.getAutoReconnect();
    _listenToStatusChanges();
    _listenToConnectivity();
    
    final currentStatus = await _vpnService.getStatus();
    _updateStatus(currentStatus);
  }

  void _listenToStatusChanges() {
    _vpnService.statusStream.listen((status) {
      _updateStatus(status);
    });
  }

  void _listenToConnectivity() {
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none && _autoReconnect && _status == VpnStatus.error) {
        _logger.log('Network restored, attempting auto-reconnect');
        _reconnect();
      }
    });
  }

  void _updateStatus(VpnStatus newStatus) {
    _status = newStatus;
    
    if (newStatus == VpnStatus.connected && _connectionStartTime == null) {
      _connectionStartTime = DateTime.now();
      _startDurationTracking();
    } else if (newStatus == VpnStatus.disconnected) {
      _connectionStartTime = null;
      _connectionDuration = Duration.zero;
    }
    
    notifyListeners();
  }

  void _startDurationTracking() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_status == VpnStatus.connected && _connectionStartTime != null) {
        _connectionDuration = DateTime.now().difference(_connectionStartTime!);
        notifyListeners();
        _startDurationTracking();
      }
    });
  }

  Future<bool> connect(VpnServer server) async {
    try {
      _errorMessage = null;
      _updateStatus(VpnStatus.connecting);
      
      final hasPermission = await _vpnService.requestVpnPermission();
      if (!hasPermission) {
        _errorMessage = 'VPN permission denied';
        _updateStatus(VpnStatus.error);
        return false;
      }
      
      final success = await _vpnService.connect(server);
      
      if (success) {
        await _storageService.setSelectedServer(server);
        return true;
      } else {
        _errorMessage = 'Failed to establish connection';
        _updateStatus(VpnStatus.error);
        return false;
      }
    } catch (e) {
      _logger.logError('Error connecting to VPN', e);
      _errorMessage = e.toString();
      _updateStatus(VpnStatus.error);
      return false;
    }
  }

  Future<bool> disconnect() async {
    try {
      _updateStatus(VpnStatus.disconnecting);
      
      final success = await _vpnService.disconnect();
      
      if (success) {
        _updateStatus(VpnStatus.disconnected);
        return true;
      } else {
        _errorMessage = 'Failed to disconnect';
        _updateStatus(VpnStatus.error);
        return false;
      }
    } catch (e) {
      _logger.logError('Error disconnecting VPN', e);
      _errorMessage = e.toString();
      _updateStatus(VpnStatus.error);
      return false;
    }
  }

  Future<void> _reconnect() async {
    final server = await _storageService.getSelectedServer();
    if (server != null) {
      await connect(server);
    }
  }

  Future<void> toggleAutoReconnect(bool value) async {
    _autoReconnect = value;
    await _storageService.setAutoReconnect(value);
    notifyListeners();
  }

  String getFormattedDuration() {
    final hours = _connectionDuration.inHours;
    final minutes = _connectionDuration.inMinutes.remainder(60);
    final seconds = _connectionDuration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
