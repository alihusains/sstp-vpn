class IpInfo {
  final String ipAddress;
  final String countryName;
  final String cityName;
  final String regionName;
  final String asnOrganization;
  final bool isProxy;
  final double? latitude;
  final double? longitude;

  IpInfo({
    required this.ipAddress,
    required this.countryName,
    required this.cityName,
    required this.regionName,
    required this.asnOrganization,
    required this.isProxy,
    this.latitude,
    this.longitude,
  });

  factory IpInfo.fromJson(Map<String, dynamic> json) {
    return IpInfo(
      ipAddress: json['ipAddress'] ?? '',
      countryName: json['countryName'] ?? 'Unknown',
      cityName: json['cityName'] ?? 'Unknown',
      regionName: json['regionName'] ?? 'Unknown',
      asnOrganization: json['asnOrganization'] ?? 'Unknown',
      isProxy: json['isProxy'] ?? false,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ipAddress': ipAddress,
      'countryName': countryName,
      'cityName': cityName,
      'regionName': regionName,
      'asnOrganization': asnOrganization,
      'isProxy': isProxy,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
