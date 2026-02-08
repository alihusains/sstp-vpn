import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/server_provider.dart';
import '../widgets/server_list_item.dart';
import '../constants/app_constants.dart';
import 'add_server_screen.dart';

class ServersScreen extends StatelessWidget {
  const ServersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VPN Servers'),
      ),
      body: Consumer<ServerProvider>(
        builder: (context, serverProvider, child) {
          if (serverProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!serverProvider.hasServers) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.dns_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No servers configured',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a server to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddServerScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Server'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: AppConstants.screenPadding,
            itemCount: serverProvider.servers.length,
            itemBuilder: (context, index) {
              final server = serverProvider.servers[index];
              final isSelected = 
                  serverProvider.selectedServer?.id == server.id;

              return Padding(
                padding: AppConstants.cardMargin,
                child: ServerListItem(
                  server: server,
                  isSelected: isSelected,
                  onTap: () {
                    serverProvider.selectServer(server);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Selected: ${server.name}'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddServerScreen(
                          server: server,
                        ),
                      ),
                    );
                  },
                  onDelete: () {
                    _showDeleteConfirmation(context, serverProvider, server.id, server.name);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddServerScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ServerProvider serverProvider,
    String serverId,
    String serverName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Server'),
        content: Text('Are you sure you want to delete "$serverName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await serverProvider.deleteServer(serverId);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Server deleted'
                          : 'Failed to delete server',
                    ),
                    backgroundColor: success ? null : AppConstants.errorColor,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppConstants.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
