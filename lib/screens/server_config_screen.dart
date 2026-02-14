import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/server_config.dart';
import '../providers/vpn_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_text_field.dart';

class ServerConfigScreen extends StatefulWidget {
  const ServerConfigScreen({super.key});

  @override
  _ServerConfigScreenState createState() => _ServerConfigScreenState();
}

class _ServerConfigScreenState extends State<ServerConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _serverAddressController = TextEditingController();
  final _portController = TextEditingController();
  final _uuidController = TextEditingController();
  final _publicKeyController = TextEditingController();
  final _shortIdController = TextEditingController();
  final _sniController = TextEditingController();
  final _spiderXController = TextEditingController();

  String _flow = 'none';
  String _encryption = 'none';
  String _fingerprint = 'chrome';

  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentServer();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _serverAddressController.dispose();
    _portController.dispose();
    _uuidController.dispose();
    _publicKeyController.dispose();
    _shortIdController.dispose();
    _sniController.dispose();
    _spiderXController.dispose();
    super.dispose();
  }

  void _loadCurrentServer() {
    final vpnProvider = Provider.of<VpnProvider>(context, listen: false);
    final currentServer = vpnProvider.currentServer;
    
    if (currentServer != null) {
      _nameController.text = currentServer.name;
      _serverAddressController.text = currentServer.serverAddress;
      _portController.text = currentServer.port.toString();
      _uuidController.text = currentServer.uuid;
      _publicKeyController.text = currentServer.publicKey ?? '';
      _shortIdController.text = currentServer.shortId ?? '';
      _sniController.text = currentServer.sni ?? '';
      _spiderXController.text = currentServer.spiderX ?? '';
      _flow = currentServer.flow ?? 'none';
      _encryption = currentServer.encryption ?? 'none';
      _fingerprint = currentServer.fingerprint ?? 'chrome';
    }
  }

  Future<void> _saveServer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final vpnProvider = Provider.of<VpnProvider>(context, listen: false);
      
      final serverConfig = ServerConfig(
        serverAddress: _serverAddressController.text.trim(),
        port: int.tryParse(_portController.text.trim()) ?? 443,
        uuid: _uuidController.text.trim(),
        flow: _flow,
        encryption: _encryption,
        publicKey: _publicKeyController.text.trim(),
        shortId: _shortIdController.text.trim(),
        sni: _sniController.text.trim(),
        fingerprint: _fingerprint,
        spiderX: _spiderXController.text.trim(),
        name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Custom Server',
      );

      // Test connection first
      final hasPermission = await vpnProvider.requestVpnPermission();
      if (!hasPermission) {
        setState(() {
          _errorMessage = 'VPN permission is required';
          _isLoading = false;
        });
        return;
      }

      // Save the server configuration
      if (vpnProvider.currentServer == null) {
        vpnProvider.addServer(serverConfig);
      } else {
        vpnProvider.updateServer(vpnProvider.currentServer!, serverConfig);
      }

      // Set as current server
      vpnProvider.selectServer(serverConfig);

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Server configuration saved successfully',
            style: AppTheme.neonBody,
          ),
          backgroundColor: AppTheme.cardColor,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save server configuration: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final vpnProvider = Provider.of<VpnProvider>(context, listen: false);
      
      final serverConfig = ServerConfig(
        serverAddress: _serverAddressController.text.trim(),
        port: int.tryParse(_portController.text.trim()) ?? 443,
        uuid: _uuidController.text.trim(),
        flow: _flow,
        encryption: _encryption,
        publicKey: _publicKeyController.text.trim(),
        shortId: _shortIdController.text.trim(),
        sni: _sniController.text.trim(),
        fingerprint: _fingerprint,
        spiderX: _spiderXController.text.trim(),
        name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Test Server',
      );

      final hasPermission = await vpnProvider.requestVpnPermission();
      if (!hasPermission) {
        setState(() {
          _errorMessage = 'VPN permission is required';
          _isLoading = false;
        });
        return;
      }

      // Test connection
      final success = await vpnProvider.connectToServer(serverConfig);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Connection test successful!',
              style: AppTheme.neonBody,
            ),
            backgroundColor: AppTheme.cardColor,
          ),
        );
        
        // Disconnect after test
        await Future.delayed(const Duration(seconds: 2));
        await vpnProvider.disconnectVpn();
      } else {
        setState(() {
          _errorMessage = 'Connection test failed';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Server Configuration',
          style: AppTheme.neonTitle.copyWith(fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: AppTheme.primaryColor),
            onPressed: _saveServer,
            tooltip: 'Save',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Server Information Section
                Text(
                  'Server Information',
                  style: AppTheme.neonSubtitle,
                ),
                const SizedBox(height: 12),
                
                NeonTextField(
                  label: 'Server Name',
                  hintText: 'Enter server name',
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a server name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                NeonTextField(
                  label: 'Server Address',
                  hintText: 'example.com',
                  controller: _serverAddressController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter server address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                NeonTextField(
                  label: 'Port',
                  hintText: '443',
                  controller: _portController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter port number';
                    }
                    final port = int.tryParse(value);
                    if (port == null || port < 1 || port > 65535) {
                      return 'Please enter a valid port number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                NeonTextField(
                  label: 'UUID',
                  hintText: '00000000-0000-0000-0000-000000000000',
                  controller: _uuidController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter UUID';
                    }
                    // Basic UUID format validation
                    final uuidRegex = RegExp(
                      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
                      caseSensitive: false,
                    );
                    if (!uuidRegex.hasMatch(value)) {
                      return 'Please enter a valid UUID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // VLESS Protocol Settings
                Text(
                  'VLESS Protocol Settings',
                  style: AppTheme.neonSubtitle,
                ),
                const SizedBox(height: 12),
                
                Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Flow',
                        style: AppTheme.neonSubtitle,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _flow,
                        items: ['none', 'xtls-rprx-vision'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _flow = newValue ?? 'none';
                          });
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: AppTheme.neonBody,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Encryption',
                        style: AppTheme.neonSubtitle,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _encryption,
                        items: ['none', 'zero'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _encryption = newValue ?? 'none';
                          });
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: AppTheme.neonBody,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fingerprint',
                        style: AppTheme.neonSubtitle,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _fingerprint,
                        items: ['chrome', 'firefox', 'safari', 'edge', 'ios', 'android'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _fingerprint = newValue ?? 'chrome';
                          });
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: AppTheme.neonBody,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Reality Settings
                Text(
                  'Reality Settings',
                  style: AppTheme.neonSubtitle,
                ),
                const SizedBox(height: 12),
                
                NeonTextField(
                  label: 'Public Key',
                  hintText: 'Enter Reality public key',
                  controller: _publicKeyController,
                ),
                const SizedBox(height: 12),
                
                NeonTextField(
                  label: 'Short ID',
                  hintText: 'Enter Reality short ID',
                  controller: _shortIdController,
                ),
                const SizedBox(height: 12),
                
                NeonTextField(
                  label: 'SNI (Server Name Indication)',
                  hintText: 'example.com',
                  controller: _sniController,
                ),
                const SizedBox(height: 12),
                
                NeonTextField(
                  label: 'Spider-X',
                  hintText: 'Optional spider-x path',
                  controller: _spiderXController,
                ),
                const SizedBox(height: 24),

                // Actions
                if (_errorMessage.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Text(
                      _errorMessage,
                      style: AppTheme.neonSecondary.copyWith(color: Colors.red),
                    ),
                  ),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _testConnection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: AppTheme.backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.network_check, size: 18),
                            const SizedBox(width: 8),
                            Text('Test Connection'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveServer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: AppTheme.backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.save, size: 18),
                            const SizedBox(width: 8),
                            Text('Save Configuration'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                ElevatedButton(
                  onPressed: _loadExampleConfig,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    foregroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_fix_high, size: 18),
                      const SizedBox(width: 8),
                      Text('Use Example Configuration'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _loadExampleConfig() {
    setState(() {
      _nameController.text = 'Example Server';
      _serverAddressController.text = 'example.com';
      _portController.text = '443';
      _uuidController.text = '00000000-0000-0000-0000-000000000000';
      _publicKeyController.text = 'your-public-key-here';
      _shortIdController.text = 'your-short-id';
      _sniController.text = 'example.com';
      _spiderXController.text = '';
      _flow = 'xtls-rprx-vision';
      _encryption = 'none';
      _fingerprint = 'chrome';
    });
  }
}