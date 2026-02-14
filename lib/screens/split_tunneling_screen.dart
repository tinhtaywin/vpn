import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_info.dart';
import '../providers/vpn_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_selector_item.dart';
import '../widgets/app_selector_header.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/neon_button.dart';
import '../widgets/loading_animation.dart';

class SplitTunnelingScreen extends StatefulWidget {
  const SplitTunnelingScreen({super.key});

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
      for (var app in allApps) {
        _toggleAppSelection(app);
      }
    } else {
      // Deselect all
      for (var app in apps) {
        _toggleAppSelection(app);
      }
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
          IconButton(
            icon: Icon(Icons.refresh, color: AppTheme.primaryColor),
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
              Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor, width: 1),
                ),
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
                    ElevatedButton(
                      onPressed: () {
                        // Toggle bypass mode
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cardColor,
                        foregroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text(
                        'Bypass VPN',
                        style: AppTheme.neonSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // App List
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: AppTheme.primaryColor,
                              strokeWidth: 4,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading apps...',
                              style: AppTheme.neonSecondary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'This may take a moment',
                              style: AppTheme.neonSecondary,
                            ),
                          ],
                        ),
                      )
                    : _errorMessage.isNotEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _errorMessage,
                                  style: AppTheme.neonSecondary,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: _loadApps,
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
                                          Icon(Icons.refresh, size: 18),
                                          const SizedBox(width: 8),
                                          Text('Retry'),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _errorMessage = '';
                                        });
                                      },
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
                                          Icon(Icons.close, size: 18),
                                          const SizedBox(width: 8),
                                          Text('Dismiss'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                            : apps.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.apps,
                                      color: AppTheme.primaryColor,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No apps found',
                                      style: AppTheme.neonSecondary,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _loadApps,
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
                                          Icon(Icons.refresh, size: 18),
                                          const SizedBox(width: 8),
                                          Text('Retry'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
              ElevatedButton(
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
                    Text('Save Selection'),
                  ],
                ),
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