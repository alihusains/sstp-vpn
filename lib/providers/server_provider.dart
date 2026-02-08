import 'package:flutter/material.dart';
import '../models/vpn_server.dart';
import '../services/storage_service.dart';
import '../services/logging_service.dart';

class ServerProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  final LoggingService _logger = LoggingService();
  
  List<VpnServer> _servers = [];
  VpnServer? _selectedServer;
  bool _isLoading = false;

  List<VpnServer> get servers => _servers;
  VpnServer? get selectedServer => _selectedServer;
  bool get isLoading => _isLoading;
  bool get hasServers => _servers.isNotEmpty;

  ServerProvider() {
    loadServers();
  }

  Future<void> loadServers() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _servers = await _storageService.loadServers();
      _selectedServer = await _storageService.getSelectedServer();
      
      _logger.log('Loaded ${_servers.length} servers');
    } catch (e) {
      _logger.logError('Error loading servers', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addServer(VpnServer server) async {
    try {
      final success = await _storageService.addServer(server);
      
      if (success) {
        _servers.add(server);
        _logger.log('Server added: ${server.name}');
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _logger.logError('Error adding server', e);
      return false;
    }
  }

  Future<bool> updateServer(VpnServer server) async {
    try {
      final success = await _storageService.updateServer(server);
      
      if (success) {
        final index = _servers.indexWhere((s) => s.id == server.id);
        if (index != -1) {
          _servers[index] = server;
        }
        
        if (_selectedServer?.id == server.id) {
          _selectedServer = server;
          await _storageService.setSelectedServer(server);
        }
        
        _logger.log('Server updated: ${server.name}');
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _logger.logError('Error updating server', e);
      return false;
    }
  }

  Future<bool> deleteServer(String serverId) async {
    try {
      final success = await _storageService.deleteServer(serverId);
      
      if (success) {
        _servers.removeWhere((s) => s.id == serverId);
        
        if (_selectedServer?.id == serverId) {
          _selectedServer = null;
          await _storageService.clearSelectedServer();
        }
        
        _logger.log('Server deleted: $serverId');
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _logger.logError('Error deleting server', e);
      return false;
    }
  }

  Future<void> selectServer(VpnServer server) async {
    try {
      _selectedServer = server;
      await _storageService.setSelectedServer(server);
      _logger.log('Server selected: ${server.name}');
      notifyListeners();
    } catch (e) {
      _logger.logError('Error selecting server', e);
    }
  }

  void clearSelection() {
    _selectedServer = null;
    _storageService.clearSelectedServer();
    notifyListeners();
  }
}
