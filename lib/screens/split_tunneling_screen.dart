import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_info.dart';
import '../providers/vpn_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_selector_item.dart';
import '../widgets/app_selector_header.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_card.dart';
import '../widgets/loading_animation.dart';

class SplitTunnelingScreen extends StatefulWidget {
  const SplitTunnelingScreen({Key? key}) : super(key: key);

  @override
  _SplitTunnelingScreenState createState() => _SplitTunnelingScreenState();
}

class _SplitTunnelingScreenState extends State<SplitTunnelingScreen> {
  String _searchQuery = '';
  bool _showSystemApps = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final vpnProvider = Provider.of<VpnProvider>(context, listen: false);
      await vpnProvider.loadInstalledApps();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load apps: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleAppSelection(AppInfo app) {
    final vpnProvider = Provider.of<VpnProvider>(context, listen: false);
    vpnProvider.toggleAppSelection(app);
  }

  void _toggleSystemApps(bool value) {
    setState(() {
      _showSystemApps = value;
    });
  }

  void _toggleSelectAll(bool value) {
    final vpnProvider = Provider.of<VpnProvider>(context, listen: false);
    final apps = vpnProvider.allowedApps;
    final allApps = vpnProvider.allowedApps; // This should be all available apps
    
    if (value) {
      // Select all
      // Note: In a real implementation, you'd get all available apps from the provider
      // For now, we'll just select all currently loaded apps
      allApps.forEach((app) => _toggleAppSelection(app));
    } else {
      // Deselect all
      apps.forEach((app) => _toggleAppSelection(app));
    }
  }

  bool get _isAllSelected {
    final vpnProvider = Provider.of<VpnProvider>(context, listen: false);
    final apps = vpnProvider.allowedApps;
    // In a real implementation, you'd check against all available apps
    return apps.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final vpnProvider = Provider.of<VpnProvider>(context);
    final apps = vpnProvider.allowedApps;
    final selectedApps = vpnProvider.allowedApps.where((app) => app.isSelected).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Split Tunneling',
          style: AppTheme.neonTitle.copyWith(fontSize: 20),
        ),
        actions: [
          NeonIconButton(
            icon: Icons.refresh,
            onPressed: _loadApps,
            tooltip: 'Refresh Apps',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header with stats
              AppSelectorHeader(
                totalApps: apps.length,
                selectedApps: selectedApps.length,
                showSystemApps: _showSystemApps,
                onShowSystemAppsChanged: _toggleSystemApps,
                onSelectAllChanged: _toggleSelectAll,
                isAllSelected: _isAllSelected,
              ),
              
              const SizedBox(height: 12),

              // Search Bar
              AppSearchBar(
                query: _searchQuery,
                onQueryChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
                onClear: () {
                  setState(() {
                    _searchQuery = '';
                  });
                },
              ),
              
              const SizedBox(height: 12),

              // Mode Toggle
              NeonCard(
                margin: EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.router,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'VPN Mode:',
                        style: AppTheme.neonSecondary,
                      ),
                      const Spacer(),
                      NeonToggleButton(
                        text: 'Bypass VPN',
                        isSelected: false, // This would be managed by settings
                        onPressed: () {
                          // Toggle bypass mode
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // App List
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            NeonLoadingSpinner(
                              text: 'Loading apps...',
                              size: 60,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'This may take a moment',
                              style: AppTheme.neonSecondary,
                            ),
                          ],
                        ),
                      )
                    : _errorMessage.isNotEmpty
                        ? NeonErrorWidget(
                            message: _errorMessage,
                            onRetry: _loadApps,
                            onDismiss: () {
                              setState(() {
                                _errorMessage = '';
                              });
                            },
                          )
                        : apps.isEmpty
                            ? NeonPlaceholder(
                                message: 'No apps found',
                                icon: Icons.apps,
                                onRetry: _loadApps,
                              )
                            : AppSelectorList(
                                apps: apps,
                                selectedApps: selectedApps,
                                onToggleApp: _toggleAppSelection,
                                onAppLongPress: (app) {
                                  // Show app details
                                  _showAppDetails(app);
                                },
                                showSystemApps: _showSystemApps,
                                searchQuery: _searchQuery,
                              ),
              ),

              // Save Button
              const SizedBox(height: 12),
              NeonButton(
                text: 'Save Selection',
                onPressed: () {
                  final vpnProvider = Provider.of<VpnProvider>(context, listen: false);
                  vpnProvider.setAllowedApps(selectedApps);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'App selection saved successfully',
                        style: AppTheme.neonBody,
                      ),
                      backgroundColor: AppTheme.cardColor,
                    ),
                  );
                  
                  Navigator.pop(context);
                },
                color: AppTheme.primaryColor,
                icon: Icons.save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAppDetails(AppInfo app) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          app.appName,
          style: AppTheme.neonSubtitle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Package: ${app.packageName}',
              style: AppTheme.neonSecondary,
            ),
            const SizedBox(height: 8),
            if (app.versionName != null)
              Text(
                'Version: ${app.versionName}',
                style: AppTheme.neonSecondary,
              ),
            const SizedBox(height: 8),
            Text(
              'System App: ${app.isSystemApp ? 'Yes' : 'No'}',
              style: AppTheme.neonSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              'Selected: ${app.isSelected ? 'Yes' : 'No'}',
              style: AppTheme.neonSecondary,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: AppTheme.neonSecondary,
            ),
          ),
        ],
      ),
    );
  }
}