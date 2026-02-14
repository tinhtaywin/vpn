import 'dart:async';
import 'dart:math';
import '../models/vpn_status.dart';
import '../models/server_config.dart';
import '../models/app_info.dart';
import '../models/traffic_stats.dart';

class VpnService {
  // Mock data management
  VpnStatus _currentStatus = VpnStatus(state: VpnState.disconnected);
  final StreamController<VpnStatus> _statusController = StreamController.broadcast(sync: true);
  final StreamController<TrafficStats> _trafficController = StreamController.broadcast();
  final StreamController<String> _errorController = StreamController.broadcast();
  
  // Mock traffic data
  int _totalUploadBytes = 0;
  int _totalDownloadBytes = 0;
  DateTime? _connectionStartTime;
  Timer? _trafficTimer;

  // Event streams
  Stream<VpnStatus>? _statusStream;
  Stream<TrafficStats>? _trafficStream;
  Stream<String>? _errorStream;

  static Future<Map<String, dynamic>> get platformVersion async {
    return {
      'platform': 'Mock Platform',
      'version': '1.0.0',
      'isDemo': true
    };
  }

  static Future<bool> connect(Map<String, dynamic> config) async {
    return true;
  }

  static Future<bool> disconnect() async {
    return true;
  }

  static Future<Map<String, dynamic>> getStatus() async {
    return {
      'state': 'disconnected',
      'serverName': null,
      'serverAddress': null,
      'port': null,
      'uploadBytes': 0,
      'downloadBytes': 0,
      'connectedAt': null
    };
  }

  static Future<bool> isSupported() async {
    return true;
  }

  // New methods required by VpnProvider
  Future<bool> requestVpnPermission() async {
    return true; // Always succeed in demo mode
  }

  Future<bool> connectVpn(ServerConfig server) async {
    // Simulate 2-second connection delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Update status to connected
    _connectionStartTime = DateTime.now();
    _currentStatus = VpnStatus(
      state: VpnState.connected,
      serverName: server.name,
      serverAddress: server.serverAddress,
      port: server.port,
      uploadBytes: 0,
      downloadBytes: 0,
      connectedAt: _connectionStartTime,
    );
    
    // Notify status stream
    _statusController.add(_currentStatus);
    
    // Start traffic simulation
    _startTrafficSimulation();
    
    return true;
  }

  Future<bool> disconnectVpn() async {
    // Stop traffic simulation
    _stopTrafficSimulation();
    
    // Update status to disconnected
    _currentStatus = VpnStatus(state: VpnState.disconnected);
    _connectionStartTime = null;
    
    // Notify status stream
    _statusController.add(_currentStatus);
    
    return true;
  }

  Future<Map<String, dynamic>> getVpnStatus() async {
    return {
      'state': _currentStatus.state.toString().split('.').last,
      'serverName': _currentStatus.serverName,
      'serverAddress': _currentStatus.serverAddress,
      'port': _currentStatus.port,
      'uploadBytes': _currentStatus.uploadBytes,
      'downloadBytes': _currentStatus.downloadBytes,
      'connectedAt': _currentStatus.connectedAt?.millisecondsSinceEpoch,
    };
  }

  Future<void> setAllowedApps(List<AppInfo> apps) async {
    // Mock implementation - just print for demo
    print('Mock: Setting allowed apps: ${apps.length} apps');
  }

  Future<List<AppInfo>> getInstalledApps() async {
    // Return mock app list for demo
    return [
      AppInfo(packageName: 'com.example.browser', appName: 'Example Browser', isSelected: true),
      AppInfo(packageName: 'com.example.email', appName: 'Example Email', isSelected: false),
      AppInfo(packageName: 'com.example.social', appName: 'Example Social', isSelected: true),
      AppInfo(packageName: 'com.example.game', appName: 'Example Game', isSelected: false),
    ];
  }

  // Event streams
  Stream<VpnStatus> get statusStream {
    return _statusController.stream;
  }

  Stream<TrafficStats> get trafficStream {
    return _trafficController.stream;
  }

  Stream<String> get errorStream {
    return _errorController.stream;
  }

  // Mock traffic simulation methods
  void _startTrafficSimulation() {
    _trafficTimer?.cancel();
    _trafficTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_currentStatus.state == VpnState.connected) {
        // Generate random traffic data
        final random = Random();
        final uploadBytes = random.nextInt(50000) + 10000; // 10KB to 60KB
        final downloadBytes = random.nextInt(100000) + 50000; // 50KB to 150KB
        
        _totalUploadBytes += uploadBytes;
        _totalDownloadBytes += downloadBytes;
        
        final now = DateTime.now();
        final trafficStats = TrafficStats(
          totalUploadBytes: _totalUploadBytes,
          totalDownloadBytes: _totalDownloadBytes,
          currentUploadBytes: uploadBytes,
          currentDownloadBytes: downloadBytes,
          startTime: _connectionStartTime ?? now,
          lastUpdate: now,
          uploadBytes: uploadBytes,
          downloadBytes: downloadBytes,
          timestamp: now,
        );
        
        _trafficController.add(trafficStats);
      }
    });
  }

  void _stopTrafficSimulation() {
    _trafficTimer?.cancel();
    _trafficTimer = null;
    _totalUploadBytes = 0;
    _totalDownloadBytes = 0;
  }

  void dispose() {
    _statusController.close();
    _trafficController.close();
    _errorController.close();
    _trafficTimer?.cancel();
  }
}
