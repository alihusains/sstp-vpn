import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vpn_provider.dart';
import '../constants/app_constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          Consumer<VpnProvider>(
            builder: (context, vpnProvider, child) {
              return SwitchListTile(
                title: const Text('Auto-Reconnect'),
                subtitle: const Text(
                  'Automatically reconnect when network is restored',
                ),
                value: vpnProvider.autoReconnect,
                onChanged: (value) {
                  vpnProvider.toggleAutoReconnect(value);
                },
                secondary: const Icon(Icons.sync),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: Text('Version ${AppConstants.appVersion}'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: AppConstants.appName,
                applicationVersion: AppConstants.appVersion,
                applicationIcon: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.vpn_lock,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'A production-ready SSTP VPN client for Android and iOS.',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This app allows you to connect to SSTP VPN servers securely.',
                  ),
                ],
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Features',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                _FeatureItem(
                  icon: Icons.security,
                  text: 'Secure SSTP protocol over port 443',
                ),
                _FeatureItem(
                  icon: Icons.public,
                  text: 'Real-time IP address tracking',
                ),
                _FeatureItem(
                  icon: Icons.dns,
                  text: 'Multiple server management',
                ),
                _FeatureItem(
                  icon: Icons.lock,
                  text: 'Encrypted credential storage',
                ),
                _FeatureItem(
                  icon: Icons.sync,
                  text: 'Auto-reconnect on network restore',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
