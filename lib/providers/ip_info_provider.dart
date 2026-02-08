import 'package:flutter/material.dart';
import '../models/ip_info.dart';
import '../services/ip_api_service.dart';
import '../services/logging_service.dart';

class IpInfoProvider with ChangeNotifier {
  final IpApiService _ipApiService = IpApiService();
  final LoggingService _logger = LoggingService();
  
  IpInfo? _beforeConnectionInfo;
  IpInfo? _afterConnectionInfo;
  bool _isLoading = false;
  String? _errorMessage;

  IpInfo? get beforeConnectionInfo => _beforeConnectionInfo;
  IpInfo? get afterConnectionInfo => _afterConnectionInfo;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchBeforeConnectionInfo() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _logger.log('Fetching IP info before connection');
      final info = await _ipApiService.fetchIpInfo();
      
      if (info != null) {
        _beforeConnectionInfo = info;
        _logger.log('Before connection IP: ${info.ipAddress}');
      } else {
        _errorMessage = 'Failed to fetch IP information';
      }
    } catch (e) {
      _logger.logError('Error fetching before connection IP', e);
      _errorMessage = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAfterConnectionInfo() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      _logger.log('Fetching IP info after connection');
      
      await Future.delayed(const Duration(seconds: 2));
      
      final info = await _ipApiService.fetchIpInfo();
      
      if (info != null) {
        _afterConnectionInfo = info;
        _logger.log('After connection IP: ${info.ipAddress}');
      } else {
        _errorMessage = 'Failed to fetch IP information';
      }
    } catch (e) {
      _logger.logError('Error fetching after connection IP', e);
      _errorMessage = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearAfterConnectionInfo() {
    _afterConnectionInfo = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    await fetchBeforeConnectionInfo();
  }
}
