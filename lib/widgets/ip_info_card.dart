import 'package:flutter/material.dart';
import '../models/ip_info.dart';
import '../constants/app_constants.dart';

class IpInfoCard extends StatelessWidget {
  final String title;
  final IpInfo? ipInfo;
  final bool isLoading;
  final VoidCallback? onRefresh;

  const IpInfoCard({
    super.key,
    required this.title,
    this.ipInfo,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Padding(
        padding: AppConstants.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onRefresh != null)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: isLoading ? null : onRefresh,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (ipInfo != null)
              Column(
                children: [
                  _buildInfoRow(
                    context,
                    Icons.public,
                    'IP Address',
                    ipInfo!.ipAddress,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    Icons.flag,
                    'Country',
                    ipInfo!.countryName,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    Icons.location_city,
                    'City',
                    ipInfo!.cityName,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    Icons.map,
                    'Region',
                    ipInfo!.regionName,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    Icons.business,
                    'ISP/Organization',
                    ipInfo!.asnOrganization,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context,
                    Icons.security,
                    'Proxy Status',
                    ipInfo!.isProxy ? 'Yes' : 'No',
                  ),
                ],
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No IP information available',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppConstants.iconSize,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
