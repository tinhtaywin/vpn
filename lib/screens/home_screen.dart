import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vpn_status.dart';
import '../providers/vpn_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/connection_status_indicator.dart';
import '../widgets/traffic_display.dart';
import '../widgets/neon_button.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _connectButtonController;
  late Animation<double> _connectButtonScaleAnimation;
  late Animation<Color?> _connectButtonColorAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void dispose() {
    _connectButtonController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _connectButtonController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _connectButtonScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _connectButtonController, curve: Curves.easeInOut),
    );

    _connectButtonColorAnimation = ColorTween(begin: AppTheme.primaryColor, end: AppTheme.secondaryColor).animate(
      CurvedAnimation(parent: _connectButtonController, curve: Curves.easeInOut),
    );
  }

  void _handleConnectionToggle(VpnProvider vpnProvider) {
    final status = vpnProvider.currentStatus;
    
    if (status.state == VpnState.disconnected) {
      // Connect to VPN
      final currentServer = vpnProvider.currentServer;
      if (currentServer != null) {
        vpnProvider.connectToServer(currentServer);
      } else {
        // Show error or navigate to server config
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please configure a server first',
              style: AppTheme.neonBody,
            ),
            backgroundColor: AppTheme.cardColor,
          ),
        );
      }
    } else {
      // Disconnect VPN
      vpnProvider.disconnectVpn();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vpnProvider = Provider.of<VpnProvider>(context);
    final status = vpnProvider.currentStatus;

    // Update animations based on connection state
    if (status.state == VpnState.connected) {
      _connectButtonController.forward();
    } else {
      _connectButtonController.reverse();
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: AppTheme.buildGlowingText(
          'VLESS VPN',
          style: AppTheme.neonTitle.copyWith(fontSize: 24),
          glowColor: AppTheme.primaryColor,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: AppTheme.primaryColor),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            tooltip: 'Settings',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Connection Status Section
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Large Connection Status Indicator
                    PulsingConnectionIndicator(
                      status: status,
                      size: 120,
                    ),
                    const SizedBox(height: 24),
                    
                    // Connection Status Text
                    ConnectionStatusIndicator(
                      status: status,
                      size: 24,
                      showText: true,
                    ),
                    const SizedBox(height: 16),
                    
                    // Server Information
                    if (status.serverName.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderColor, width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppTheme.primaryColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              status.serverName,
                              style: AppTheme.neonSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${status.serverAddress}:${status.port})',
                              style: AppTheme.neonSecondary.copyWith(
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              
              // Connection Button
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _connectButtonController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _connectButtonScaleAnimation.value,
                          child: child,
                        );
                      },
                      child: NeonButton(
                        text: _getButtonText(status.state),
                        onPressed: () => _handleConnectionToggle(vpnProvider),
                        color: _connectButtonColorAnimation.value ?? AppTheme.primaryColor,
                        width: 200,
                        height: 60,
                        icon: _getButtonIcon(status.state),
                        isLoading: status.state == VpnState.connecting || status.state == VpnState.disconnecting,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (status.state == VpnState.connected)
                      Text(
                        'Connected for ${status.connectionTime}',
                        style: AppTheme.neonSecondary,
                      ),
                  ],
                ),
              ),
              
              // Traffic Statistics
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Traffic Statistics',
                      style: AppTheme.neonSubtitle,
                    ),
                    const SizedBox(height: 12),
                    TrafficDisplay(
                      uploadBytes: status.uploadBytes,
                      downloadBytes: status.downloadBytes,
                      showDetails: true,
                      height: 140,
                    ),
                  ],
                ),
              ),
              
              // Quick Actions
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: AppTheme.neonSubtitle,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/split-tunneling');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: vpnProvider.allowedApps.isNotEmpty 
                                ? AppTheme.primaryColor 
                                : AppTheme.cardColor,
                            foregroundColor: vpnProvider.allowedApps.isNotEmpty 
                                ? AppTheme.backgroundColor 
                                : AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: vpnProvider.allowedApps.isNotEmpty 
                                    ? AppTheme.primaryColor 
                                    : AppTheme.borderColor,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: Text('Split Tunnel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/server-config');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: vpnProvider.currentServer != null 
                                ? AppTheme.primaryColor 
                                : AppTheme.cardColor,
                            foregroundColor: vpnProvider.currentServer != null 
                                ? AppTheme.backgroundColor 
                                : AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: vpnProvider.currentServer != null 
                                    ? AppTheme.primaryColor 
                                    : AppTheme.borderColor,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: Text('Server Config'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getButtonText(VpnState state) {
    switch (state) {
      case VpnState.connected:
        return 'Disconnect';
      case VpnState.connecting:
        return 'Connecting...';
      case VpnState.disconnecting:
        return 'Disconnecting...';
      case VpnState.error:
        return 'Retry Connection';
      case VpnState.disconnected:
      default:
        return 'Connect VPN';
    }
  }

  IconData _getButtonIcon(VpnState state) {
    switch (state) {
      case VpnState.connected:
        return Icons.vpn_lock;
      case VpnState.connecting:
        return Icons.sync;
      case VpnState.disconnecting:
        return Icons.vpn_key;
      case VpnState.error:
        return Icons.error;
      case VpnState.disconnected:
      default:
        return Icons.vpn_lock_outlined;
    }
  }
}