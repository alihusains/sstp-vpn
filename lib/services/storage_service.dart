import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vpn_server.dart';
import 'logging_service.dart';

class StorageService {
  static const String _serversKey = 'vpn_servers';
  static const String _selectedServerKey = 'selected_server';
  static const String _autoReconnectKey = 'auto_reconnect';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LoggingService _logger = LoggingService();

  Future<List<VpnServer>> loadServers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serversJson = prefs.getString(_serversKey);
      
      if (serversJson == null) {
        return [];
      }
      
      final List<dynamic> serversList = json.decode(serversJson);
      return serversList.map((json) => VpnServer.fromJson(json)).toList();
    } catch (e) {
      _logger.log('Error loading servers: $e');
      return [];
    }
  }

  Future<bool> saveServers(List<VpnServer> servers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serversJson = json.encode(servers.map((s) => s.toJson()).toList());
      return await prefs.setString(_serversKey, serversJson);
    } catch (e) {
      _logger.log('Error saving servers: $e');
      return false;
    }
  }

  Future<bool> addServer(VpnServer server) async {
    final servers = await loadServers();
    servers.add(server);
    return await saveServers(servers);
  }

  Future<bool> updateServer(VpnServer server) async {
    final servers = await loadServers();
    final index = servers.indexWhere((s) => s.id == server.id);
    
    if (index != -1) {
      servers[index] = server;
      return await saveServers(servers);
    }
    
    return false;
  }

  Future<bool> deleteServer(String serverId) async {
    final servers = await loadServers();
    servers.removeWhere((s) => s.id == serverId);
    return await saveServers(servers);
  }

  Future<VpnServer?> getSelectedServer() async {
    try {
      final serverJson = await _secureStorage.read(key: _selectedServerKey);
      
      if (serverJson == null) {
        return null;
      }
      
      return VpnServer.fromJson(json.decode(serverJson));
    } catch (e) {
      _logger.log('Error getting selected server: $e');
      return null;
    }
  }

  Future<bool> setSelectedServer(VpnServer server) async {
    try {
      final serverJson = json.encode(server.toJson());
      await _secureStorage.write(key: _selectedServerKey, value: serverJson);
      return true;
    } catch (e) {
      _logger.log('Error setting selected server: $e');
      return false;
    }
  }

  Future<bool> clearSelectedServer() async {
    try {
      await _secureStorage.delete(key: _selectedServerKey);
      return true;
    } catch (e) {
      _logger.log('Error clearing selected server: $e');
      return false;
    }
  }

  Future<bool> getAutoReconnect() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_autoReconnectKey) ?? false;
    } catch (e) {
      _logger.log('Error getting auto-reconnect setting: $e');
      return false;
    }
  }

  Future<bool> setAutoReconnect(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_autoReconnectKey, value);
    } catch (e) {
      _logger.log('Error setting auto-reconnect: $e');
      return false;
    }
  }
}
