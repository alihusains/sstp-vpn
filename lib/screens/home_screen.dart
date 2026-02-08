import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vpn_provider.dart';
import '../providers/ip_info_provider.dart';
import '../providers/server_provider.dart';
import '../models/vpn_status.dart';
import '../widgets/ip_info_card.dart';
import '../widgets/connection_button.dart';
import '../widgets/status_indicator.dart';
import '../constants/app_constants.dart';
import 'servers_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IpInfoProvider>().fetchBeforeConnectionInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.dns),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ServersScreen(),
                ),
              );
            },
            tooltip: 'Servers',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppConstants.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Consumer<VpnProvider>(
                builder: (context, vpnProvider, child) {
                  return Column(
                    children: [
                      StatusIndicator(
                        status: vpnProvider.status,
                        duration: vpnProvider.isConnected
                            ? vpnProvider.getFormattedDuration()
                            : null,
                      ),
                      if (vpnProvider.errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppConstants.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppConstants.errorColor,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: AppConstants.errorColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  vpnProvider.errorMessage!,
                                  style: TextStyle(
                                    color: AppConstants.errorColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Consumer<IpInfoProvider>(
                builder: (context, ipProvider, child) {
                  return IpInfoCard(
                    title: 'Current IP Info',
                    ipInfo: ipProvider.beforeConnectionInfo,
                    isLoading: ipProvider.isLoading,
                    onRefresh: () => ipProvider.fetchBeforeConnectionInfo(),
                  );
                },
              ),
              const SizedBox(height: 16),
              Consumer<VpnProvider>(
                builder: (context, vpnProvider, child) {
                  if (vpnProvider.isConnected) {
                    return Consumer<IpInfoProvider>(
                      builder: (context, ipProvider, child) {
                        return IpInfoCard(
                          title: 'VPN IP Info',
                          ipInfo: ipProvider.afterConnectionInfo,
                          isLoading: ipProvider.isLoading,
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 32),
              Consumer<ServerProvider>(
                builder: (context, serverProvider, child) {
                  final selectedServer = serverProvider.selectedServer;
                  
                  return Column(
                    children: [
                      if (selectedServer != null)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.dns),
                            title: Text(selectedServer.name),
                            subtitle: Text(selectedServer.serverAddress),
                            trailing: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ServersScreen(),
                                  ),
                                );
                              },
                              child: const Text('Change'),
                            ),
                          ),
                        )
                      else
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: const Text('No server selected'),
                            subtitle: const Text('Add a server to connect'),
                            trailing: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ServersScreen(),
                                  ),
                                );
                              },
                              child: const Text('Add Server'),
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                      Consumer<VpnProvider>(
                        builder: (context, vpnProvider, child) {
                          return ConnectionButton(
                            status: vpnProvider.status,
                            enabled: selectedServer != null,
                            onPressed: () => _handleConnectionToggle(
                              context,
                              vpnProvider,
                              serverProvider,
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleConnectionToggle(
    BuildContext context,
    VpnProvider vpnProvider,
    ServerProvider serverProvider,
  ) async {
    final ipProvider = context.read<IpInfoProvider>();
    
    if (vpnProvider.status == VpnStatus.disconnected || 
        vpnProvider.status == VpnStatus.error) {
      final server = serverProvider.selectedServer;
      
      if (server == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a server first'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
        return;
      }
      
      final success = await vpnProvider.connect(server);
      
      if (success) {
        await Future.delayed(const Duration(seconds: 2));
        ipProvider.fetchAfterConnectionInfo();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Connected successfully'),
              backgroundColor: AppConstants.connectedColor,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(vpnProvider.errorMessage ?? 'Connection failed'),
              backgroundColor: AppConstants.errorColor,
            ),
          );
        }
      }
    } else if (vpnProvider.status == VpnStatus.connected) {
      final success = await vpnProvider.disconnect();
      
      if (success) {
        ipProvider.clearAfterConnectionInfo();
        ipProvider.fetchBeforeConnectionInfo();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Disconnected successfully'),
            ),
          );
        }
      }
    }
  }
}
