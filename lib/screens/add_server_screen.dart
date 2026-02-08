import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vpn_server.dart';
import '../providers/server_provider.dart';
import '../constants/app_constants.dart';

class AddServerScreen extends StatefulWidget {
  final VpnServer? server;

  const AddServerScreen({super.key, this.server});

  @override
  State<AddServerScreen> createState() => _AddServerScreenState();
}

class _AddServerScreenState extends State<AddServerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _portController = TextEditingController(text: '443');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.server != null) {
      _nameController.text = widget.server!.name;
      _addressController.text = widget.server!.serverAddress;
      _portController.text = widget.server!.port.toString();
      _usernameController.text = widget.server!.username;
      _passwordController.text = widget.server!.password;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.server != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Server' : 'Add Server'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppConstants.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Server Name',
                    hintText: 'e.g., My VPN Server',
                    prefixIcon: Icon(Icons.label),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a server name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Server Address',
                    hintText: 'e.g., vpn.example.com',
                    prefixIcon: Icon(Icons.dns),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a server address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _portController,
                  decoration: const InputDecoration(
                    labelText: 'Port',
                    hintText: '443',
                    prefixIcon: Icon(Icons.settings_ethernet),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a port number';
                    }
                    final port = int.tryParse(value);
                    if (port == null || port < 1 || port > 65535) {
                      return 'Please enter a valid port (1-65535)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Credentials are stored securely on your device',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveServer,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEditing ? 'Update Server' : 'Add Server'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveServer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final serverProvider = context.read<ServerProvider>();
    
    final server = VpnServer(
      id: widget.server?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      serverAddress: _addressController.text.trim(),
      port: int.parse(_portController.text.trim()),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    bool success;
    if (widget.server != null) {
      success = await serverProvider.updateServer(server);
    } else {
      success = await serverProvider.addServer(server);
    }

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.server != null
                  ? 'Server updated successfully'
                  : 'Server added successfully',
            ),
            backgroundColor: AppConstants.connectedColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.server != null
                  ? 'Failed to update server'
                  : 'Failed to add server',
            ),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }
}
