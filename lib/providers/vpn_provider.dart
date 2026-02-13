import 'dart:async';
import 'package:flutter/material.dart';
import '../models/server_config.dart';
import '../models/vpn_status.dart';
import '../models/app_info.dart';
import '../models/traffic_stats.dart';
import '../services/vpn_service.dart';
import '../services/storage_service.dart';
import '../services/permission_service.dart';

class VpnProvider with ChangeNotifier {
  final VpnService _vpnService;
  final StorageService _storageService;
  final PermissionService _permissionService;

  VpnStatus _currentStatus = VpnStatus(state: VpnState.disconnected);
  List<ServerConfig> _serverConfigs = [];
  List<AppInfo> _allowedApps = [];
  ServerConfig? _currentServer;
  bool _isLoading = false;
  String _errorMessage = '';

  StreamSubscription<VpnStatus>? _statusSubscription;
  StreamSubscription<TrafficStats>? _trafficSubscription;
  StreamSubscription<String>? _errorSubscription;

  VpnProvider(this._vpnService, this._storageService, this._permissionService) {
    _initialize();
  }

  VpnStatus get currentStatus => _currentStatus;
  List<ServerConfig> get serverConfigs => _serverConfigs;
  List<AppInfo> get allowedApps => _allowedApps;
  ServerConfig? get currentServer => _currentServer;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load saved data
      await _loadData();
      
      // Set up subscriptions
      _setupSubscriptions();
      
      // Check current VPN status
      await _checkVpnStatus();
      
    } catch (e) {
      _errorMessage = e.toString();
      print('Error initializing VPN provider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupSubscriptions() {
    _statusSubscription = _vpnService.statusStream.listen((status) {
      _currentStatus = status;
      notifyListeners();
    });

    _trafficSubscription = _vpnService.trafficStream.listen((stats) {
      // Update traffic stats
      _currentStatus = _currentStatus.copyWith(
        uploadBytes: stats.uploadBytes,
        downloadBytes: stats.downloadBytes,
      );
      notifyListeners();
    });

    _errorSubscription = _vpnService.errorStream.listen((error) {
      _errorMessage = error;
      notifyListeners();
    });
  }

  Future<void> _loadData() async {
    _serverConfigs = await _storageService.getServerConfigs();
    _allowedApps = await _storageService.getAllowedApps();
    _currentServer = await _storageService.getCurrentServer();
  }

  Future<void> _checkVpnStatus() async {
    try {
      final statusData = await _vpnService.getVpnStatus();
      // Update status based on native service response
      if (statusData['connected'] == true) {
        _currentStatus = _currentStatus.copyWith(
          state: VpnState.connected,
          serverName: statusData['server'] ?? '',
          uploadBytes: statusData['upload'] ?? 0,
          downloadBytes: statusData['download'] ?? 0,
        );
      } else {
        _currentStatus = _currentStatus.copyWith(state: VpnState.disconnected);
      }
      notifyListeners();
    } catch (e) {
      print('Error checking VPN status: $e');
    }
  }

  Future<bool> requestVpnPermission() async {
    try {
      final hasPermission = await _vpnService.requestVpnPermission();
      if (hasPermission) {
        _errorMessage = '';
      } else {
        _errorMessage = 'VPN permission required';
      }
      notifyListeners();
      return hasPermission;
    } catch (e) {
      _errorMessage = 'Failed to request VPN permission: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> connectToServer(ServerConfig server) async {
    if (_isLoading) return false;

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Save current server
      await _storageService.saveCurrentServer(server);
      _currentServer = server;

      // Connect to VPN
      final success = await _vpnService.connectVpn(server);
      
      if (success) {
        _currentStatus = _currentStatus.copyWith(
          state: VpnState.connecting,
          serverName: server.name,
          serverAddress: server.serverAddress,
          port: server.port,
        );
      } else {
        _errorMessage = 'Failed to connect to VPN';
      }
      
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Connection failed: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> disconnectVpn() async {
    if (_isLoading) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final success = await _vpnService.disconnectVpn();
      
      if (success) {
        _currentStatus = _currentStatus.copyWith(state: VpnState.disconnected);
        _currentStatus = _currentStatus.copyWith(
          uploadBytes: 0,
          downloadBytes: 0,
          connectedAt: null,
        );
      } else {
        _errorMessage = 'Failed to disconnect VPN';
      }
      
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Disconnection failed: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addServer(ServerConfig server) async {
    _serverConfigs.add(server);
    await _storageService.saveServerConfigs(_serverConfigs);
    notifyListeners();
  }

  Future<void> updateServer(ServerConfig oldServer, ServerConfig newServer) async {
    final index = _serverConfigs.indexOf(oldServer);
    if (index != -1) {
      _serverConfigs[index] = newServer;
      await _storageService.saveServerConfigs(_serverConfigs);
      
      // Update current server if it was modified
      if (_currentServer?.serverAddress == oldServer.serverAddress) {
        await _storageService.saveCurrentServer(newServer);
        _currentServer = newServer;
      }
      
      notifyListeners();
    }
  }

  Future<void> deleteServer(ServerConfig server) async {
    _serverConfigs.remove(server);
    await _storageService.saveServerConfigs(_serverConfigs);
    
    // Clear current server if it was deleted
    if (_currentServer?.serverAddress == server.serverAddress) {
      _currentServer = null;
      await _storageService.saveCurrentServer(ServerConfig(
        serverAddress: '',
        port: 0,
        uuid: '',
        name: '',
      ));
    }
    
    notifyListeners();
  }

  Future<void> selectServer(ServerConfig server) async {
    _currentServer = server;
    await _storageService.saveCurrentServer(server);
    notifyListeners();
  }

  Future<void> setAllowedApps(List<AppInfo> apps) async {
    _allowedApps = apps;
    await _storageService.saveAllowedApps(apps);
    
    // Update VPN service if connected
    if (_currentStatus.state == VpnState.connected) {
      await _vpnService.setAllowedApps(apps);
    }
    
    notifyListeners();
  }

  Future<void> toggleAppSelection(AppInfo app) async {
    final index = _allowedApps.indexWhere((a) => a.packageName == app.packageName);
    if (index != -1) {
      _allowedApps[index] = app.copyWith(isSelected: !app.isSelected);
    } else {
      _allowedApps.add(app.copyWith(isSelected: true));
    }
    
    await _storageService.saveAllowedApps(_allowedApps);
    notifyListeners();
  }

  Future<void> loadInstalledApps() async {
    try {
      final apps = await _vpnService.getInstalledApps();
      _allowedApps = apps;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load installed apps: $e';
      notifyListeners();
    }
  }

  Future<void> clearError() async {
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _trafficSubscription?.cancel();
    _errorSubscription?.cancel();
    _vpnService.dispose();
    super.dispose();
  }
}