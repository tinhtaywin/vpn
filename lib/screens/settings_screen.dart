import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_card.dart';
import '../widgets/neon_switch.dart';
import '../widgets/neon_slider.dart';
import '../widgets/loading_animation.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTheme.neonTitle.copyWith(fontSize: 20),
        ),
        actions: [
          NeonIconButton(
            icon: Icons.restore,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppTheme.backgroundColor,
                  title: Text(
                    'Reset Settings',
                    style: AppTheme.neonSubtitle,
                  ),
                  content: Text(
                    'Are you sure you want to reset all settings to default?',
                    style: AppTheme.neonBody,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: AppTheme.neonSecondary,
                      ),
                    ),
                    NeonButton(
                      text: 'Reset',
                      onPressed: () {
                        settingsProvider.resetToDefaults();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Settings reset to defaults',
                              style: AppTheme.neonBody,
                            ),
                            backgroundColor: AppTheme.cardColor,
                          ),
                        );
                      },
                      color: Colors.red,
                      icon: Icons.restore,
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Reset to Defaults',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              // Connection Settings
              Text(
                'Connection Settings',
                style: AppTheme.neonSubtitle,
              ),
              const SizedBox(height: 12),
              
              NeonSwitch(
                label: 'Auto Connect',
                value: settingsProvider.autoConnect,
                onChanged: settingsProvider.setAutoConnect,
                description: 'Automatically connect to VPN on app startup',
              ),
              const SizedBox(height: 12),
              
              NeonSwitch(
                label: 'Kill Switch',
                value: settingsProvider.killSwitch,
                onChanged: settingsProvider.setKillSwitch,
                description: 'Block all internet if VPN disconnects',
              ),
              const SizedBox(height: 12),
              
              NeonCard(
                margin: EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Custom DNS',
                        style: AppTheme.neonSubtitle,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: AppTheme.inputDecorationTheme.copyWith(
                          hintText: '8.8.8.8, 8.8.4.4',
                          hintStyle: AppTheme.neonSecondary.copyWith(
                            color: AppTheme.secondaryTextColor.withOpacity(0.6),
                          ),
                          labelText: 'DNS Servers',
                        ),
                        style: AppTheme.neonBody,
                        onChanged: settingsProvider.setCustomDns,
                        controller: TextEditingController(text: settingsProvider.customDns),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),

              // Split Tunneling Settings
              Text(
                'Split Tunneling',
                style: AppTheme.neonSubtitle,
              ),
              const SizedBox(height: 12),
              
              NeonSwitch(
                label: 'Enable Split Tunneling',
                value: settingsProvider.splitTunneling,
                onChanged: settingsProvider.setSplitTunneling,
                description: 'Allow selected apps to bypass VPN',
              ),
              const SizedBox(height: 12),
              
              NeonSwitch(
                label: 'Bypass Mode',
                value: settingsProvider.bypassMode,
                onChanged: settingsProvider.setBypassMode,
                description: 'Selected apps bypass VPN (otherwise they use VPN)',
              ),
              const SizedBox(height: 24),

              // Performance Settings
              Text(
                'Performance',
                style: AppTheme.neonSubtitle,
              ),
              const SizedBox(height: 12),
              
              NeonCard(
                margin: EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connection Timeout',
                        style: AppTheme.neonSubtitle,
                      ),
                      const SizedBox(height: 8),
                      NeonSlider(
                        label: 'Timeout (seconds)',
                        value: 30.0, // This would be managed by settings
                        min: 10.0,
                        max: 120.0,
                        onChanged: (value) {
                          // Update timeout setting
                        },
                        divisions: 11,
                        valueLabelBuilder: (value) => '${value.toInt()}s',
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),

              // Theme Settings
              Text(
                'Theme',
                style: AppTheme.neonSubtitle,
              ),
              const SizedBox(height: 12),
              
              NeonCard(
                margin: EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme Preset',
                        style: AppTheme.neonSubtitle,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: NeonToggleButton(
                              text: 'Neon',
                              isSelected: settingsProvider.theme == 'neon',
                              onPressed: () => settingsProvider.setTheme('neon'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: NeonToggleButton(
                              text: 'Dark',
                              isSelected: settingsProvider.theme == 'dark',
                              onPressed: () => settingsProvider.setTheme('dark'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: NeonToggleButton(
                              text: 'Light',
                              isSelected: settingsProvider.theme == 'light',
                              onPressed: () => settingsProvider.setTheme('light'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),

              // Data Management
              Text(
                'Data Management',
                style: AppTheme.neonSubtitle,
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: NeonButton(
                      text: 'Clear Cache',
                      onPressed: settingsProvider.clearCache,
                      color: AppTheme.accentColor,
                      icon: Icons.delete,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeonButton(
                      text: 'Clear All Data',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppTheme.backgroundColor,
                            title: Text(
                              'Clear All Data',
                              style: AppTheme.neonSubtitle,
                            ),
                            content: Text(
                              'This will delete all saved servers, settings, and traffic history. This action cannot be undone.',
                              style: AppTheme.neonBody,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Cancel',
                                  style: AppTheme.neonSecondary,
                                ),
                              ),
                              NeonButton(
                                text: 'Clear All',
                                onPressed: () {
                                  settingsProvider.clearAllData();
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'All data cleared',
                                        style: AppTheme.neonBody,
                                      ),
                                      backgroundColor: AppTheme.cardColor,
                                    ),
                                  );
                                },
                                color: Colors.red,
                                icon: Icons.delete_forever,
                              ),
                            ],
                          ),
                        );
                      },
                      color: Colors.red,
                      icon: Icons.delete_forever,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),

              // About Section
              Text(
                'About',
                style: AppTheme.neonSubtitle,
              ),
              const SizedBox(height: 12),
              
              NeonCard(
                margin: EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VLESS VPN Client',
                        style: AppTheme.neonSubtitle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Version 1.0.0',
                        style: AppTheme.neonSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'A production-ready VPN client with VLESS TCP Reality protocol support and neon-themed UI.',
                        style: AppTheme.neonBody,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          NeonIconButton(
                            icon: Icons.info,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: AppTheme.backgroundColor,
                                  title: Text(
                                    'About VLESS VPN',
                                    style: AppTheme.neonSubtitle,
                                  ),
                                  content: Text(
                                    'This app provides secure VPN connectivity using the VLESS protocol with Reality support. It features a neon-themed user interface and advanced split tunneling capabilities.',
                                    style: AppTheme.neonBody,
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
                            },
                            tooltip: 'About',
                          ),
                          const SizedBox(width: 8),
                          NeonIconButton(
                            icon: Icons.privacy_tip,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: AppTheme.backgroundColor,
                                  title: Text(
                                    'Privacy Policy',
                                    style: AppTheme.neonSubtitle,
                                  ),
                                  content: Text(
                                    'This app does not collect or transmit any personal data. All configuration is stored locally on your device.',
                                    style: AppTheme.neonBody,
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
                            },
                            tooltip: 'Privacy Policy',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}