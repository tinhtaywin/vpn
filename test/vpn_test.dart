// import 'package:flutter_test/flutter_test.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_vless_vpn/models/server_config.dart';
// import 'package:flutter_vless_vpn/models/vpn_status.dart';
// import 'package:flutter_vless_vpn/providers/vpn_provider.dart';
// import 'package:flutter_vless_vpn/providers/settings_provider.dart';
// import 'package:flutter_vless_vpn/services/storage_service.dart';
// import 'package:flutter_vless_vpn/services/permission_service.dart';
// import 'package:flutter_vless_vpn/services/vpn_service.dart';
// import 'package:flutter_vless_vpn/theme/app_theme.dart';

// void main() {
//   group('VPN App Tests', () {
//     late StorageService storageService;
//     late PermissionService permissionService;
//     late VpnService vpnService;
//     late VpnProvider vpnProvider;
//     late SettingsProvider settingsProvider;

//     setUp(() {
//       storageService = StorageService();
//       permissionService = PermissionService();
//       vpnService = VpnService();
//       vpnProvider = VpnProvider(vpnService, storageService, permissionService);
//       settingsProvider = SettingsProvider(storageService);
//     });

//     test('Server Configuration Validation', () {
//       // Test valid server configuration
//       final validServer = ServerConfig(
//         serverAddress: 'example.com',
//         port: 443,
//         uuid: '00000000-0000-0000-0000-000000000000',
//         flow: 'xtls-rprx-vision',
//         encryption: 'none',
//         publicKey: 'test-key',
//         shortId: 'test-id',
//         sni: 'example.com',
//         fingerprint: 'chrome',
//         spiderX: '',
//         name: 'Test Server',
//       );

//       expect(validServer.serverAddress, 'example.com');
//       expect(validServer.port, 443);
//       expect(validServer.uuid, '00000000-0000-0000-0000-000000000000');
//       expect(validServer.flow, 'xtls-rprx-vision');
//     });

//     test('VPN Status Updates', () {
//       // Test initial status
//       expect(vpnProvider.currentStatus.state, VpnState.disconnected);
//       expect(vpnProvider.currentStatus.serverName, '');
//       expect(vpnProvider.currentStatus.uploadBytes, 0);
//       expect(vpnProvider.currentStatus.downloadBytes, 0);

//       // Test status update
//       final newStatus = VpnStatus(
//         state: VpnState.connected,
//         serverName: 'Test Server',
//         serverAddress: 'example.com',
//         port: 443,
//         uploadBytes: 1024,
//         downloadBytes: 2048,
//         connectionTime: '00:05:00',
//       );

//       vpnProvider.updateStatus(newStatus);
//       expect(vpnProvider.currentStatus.state, VpnState.connected);
//       expect(vpnProvider.currentStatus.serverName, 'Test Server');
//       expect(vpnProvider.currentStatus.uploadBytes, 1024);
//       expect(vpnProvider.currentStatus.downloadBytes, 2048);
//     });

//     test('Settings Provider', () {
//       // Test default settings
//       expect(settingsProvider.autoConnect, false);
//       expect(settingsProvider.killSwitch, false);
//       expect(settingsProvider.splitTunneling, false);
//       expect(settingsProvider.bypassMode, false);
//       expect(settingsProvider.customDns, '');
//       expect(settingsProvider.theme, 'neon');

//       // Test setting updates
//       settingsProvider.setAutoConnect(true);
//       expect(settingsProvider.autoConnect, true);

//       settingsProvider.setKillSwitch(true);
//       expect(settingsProvider.killSwitch, true);

//       settingsProvider.setSplitTunneling(true);
//       expect(settingsProvider.splitTunneling, true);

//       settingsProvider.setBypassMode(true);
//       expect(settingsProvider.bypassMode, true);

//       settingsProvider.setCustomDns('8.8.8.8');
//       expect(settingsProvider.customDns, '8.8.8.8');

//       settingsProvider.setTheme('dark');
//       expect(settingsProvider.theme, 'dark');
//     });

//     test('App Selection', () {
//       // Test initial app selection
//       expect(vpnProvider.allowedApps, isEmpty);

//       // Test adding apps
//       final app1 = AppInfo(
//         appName: 'App 1',
//         packageName: 'com.example.app1',
//         versionName: '1.0.0',
//         isSystemApp: false,
//         iconPath: null,
//       );

//       final app2 = AppInfo(
//         appName: 'App 2',
//         packageName: 'com.example.app2',
//         versionName: '1.0.0',
//         isSystemApp: false,
//         iconPath: null,
//       );

//       vpnProvider.toggleAppSelection(app1);
//       expect(vpnProvider.allowedApps.length, 1);
//       expect(vpnProvider.allowedApps.first.packageName, 'com.example.app1');

//       vpnProvider.toggleAppSelection(app2);
//       expect(vpnProvider.allowedApps.length, 2);

//       // Test removing apps
//       vpnProvider.toggleAppSelection(app1);
//       expect(vpnProvider.allowedApps.length, 1);
//       expect(vpnProvider.allowedApps.first.packageName, 'com.example.app2');
//     });

//     test('Server Management', () {
//       // Test initial server list
//       expect(vpnProvider.servers, isEmpty);

//       // Test adding servers
//       final server1 = ServerConfig(
//         serverAddress: 'server1.com',
//         port: 443,
//         uuid: '00000000-0000-0000-0000-000000000001',
//         flow: 'none',
//         encryption: 'none',
//         publicKey: '',
//         shortId: '',
//         sni: '',
//         fingerprint: 'chrome',
//         spiderX: '',
//         name: 'Server 1',
//       );

//       final server2 = ServerConfig(
//         serverAddress: 'server2.com',
//         port: 443,
//         uuid: '00000000-0000-0000-0000-000000000002',
//         flow: 'none',
//         encryption: 'none',
//         publicKey: '',
//         shortId: '',
//         sni: '',
//         fingerprint: 'chrome',
//         spiderX: '',
//         name: 'Server 2',
//       );

//       vpnProvider.addServer(server1);
//       expect(vpnProvider.servers.length, 1);
//       expect(vpnProvider.servers.first.name, 'Server 1');

//       vpnProvider.addServer(server2);
//       expect(vpnProvider.servers.length, 2);

//       // Test selecting server
//       vpnProvider.selectServer(server1);
//       expect(vpnProvider.currentServer, server1);

//       // Test updating server
//       final updatedServer = ServerConfig(
//         serverAddress: 'updated-server.com',
//         port: 8443,
//         uuid: '00000000-0000-0000-0000-000000000001',
//         flow: 'xtls-rprx-vision',
//         encryption: 'none',
//         publicKey: 'updated-key',
//         shortId: 'updated-id',
//         sni: 'updated.com',
//         fingerprint: 'firefox',
//         spiderX: '/updated',
//         name: 'Updated Server',
//       );

//       vpnProvider.updateServer(server1, updatedServer);
//       expect(vpnProvider.currentServer?.serverAddress, 'updated-server.com');
//       expect(vpnProvider.currentServer?.port, 8443);
//       expect(vpnProvider.currentServer?.flow, 'xtls-rprx-vision');
//     });

//     test('Theme Colors', () {
//       // Test theme colors are properly defined
//       expect(AppTheme.primaryColor, isNotNull);
//       expect(AppTheme.secondaryColor, isNotNull);
//       expect(AppTheme.accentColor, isNotNull);
//       expect(AppTheme.backgroundColor, isNotNull);
//       expect(AppTheme.cardColor, isNotNull);
//       expect(AppTheme.textColor, isNotNull);
//       expect(AppTheme.secondaryTextColor, isNotNull);
//       expect(AppTheme.borderColor, isNotNull);

//       // Test gradient is properly defined
//       expect(AppTheme.neonGradient, isNotNull);
//     });

//     test('Traffic Statistics', () {
//       // Test initial traffic stats
//       final initialStats = TrafficStats(
//         uploadBytes: 0,
//         downloadBytes: 0,
//         timestamp: DateTime.now(),
//       );

//       expect(initialStats.uploadBytes, 0);
//       expect(initialStats.downloadBytes, 0);

//       // Test traffic update
//       final updatedStats = TrafficStats(
//         uploadBytes: 1048576, // 1MB
//         downloadBytes: 2097152, // 2MB
//         timestamp: DateTime.now(),
//       );

//       expect(updatedStats.uploadBytes, 1048576);
//       expect(updatedStats.downloadBytes, 2097152);
//     });
//   });
// }