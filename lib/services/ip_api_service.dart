import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ip_info.dart';
import 'logging_service.dart';

class IpApiService {
  static const String _apiUrl = 'https://free.freeipapi.com/api/json';
  final LoggingService _logger = LoggingService();

  Future<IpInfo?> fetchIpInfo() async {
    try {
      _logger.log('Fetching IP info from $_apiUrl');
      
      final response = await http.get(
        Uri.parse(_apiUrl),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _logger.log('IP info fetched successfully: ${data['ipAddress']}');
        return IpInfo.fromJson(data);
      } else {
        _logger.log('Failed to fetch IP info. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.log('Error fetching IP info: $e');
      return null;
    }
  }
}
