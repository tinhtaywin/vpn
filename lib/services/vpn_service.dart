import 'dart:async';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/server_config.dart';
import '../models/vpn_status.dart';
import '../models/app_info.dart';
import '../models/traffic_stats.dart';

class VpnService {
  static const MethodChannel _methodChannel = MethodChannel('com.example.flutter_vless_vpn/vpn_service');
  static const EventChannel _eventChannel = EventChannel('com.example.flutter_vless_vpn/vpn_events');

  final StreamController<VpnStatus> _statusController = StreamController.broadcast();
  final StreamController<TrafficStats> _trafficController = StreamController.broadcast();
  final StreamController<String> _errorController = StreamController.broadcast();

  Stream<VpnStatus> get statusStream => _statusController.stream;
  Stream<TrafficStats> get trafficStream => _trafficController.stream;
  Stream<String> get errorStream => _errorController.stream;

  VpnStatus currentStatus = VpnStatus(state: VpnState.disconnected);

  VpnService() {
    _setupEventChannel();
  }

  void _setupEventChannel() {
    _eventChannel.receiveBroadcastStream().listen((event) {
      if (event is Map) {
        final type = event['type'] as String?;
        final data = event['data'] as Map<String, dynamic>?;

        switch (type) {
          case 'status_update':
            _handleStatusUpdate(data);
            break;
          case 'traffic_update':
            _handleTrafficUpdate(data);
            break;
        }
      }
    });
  }

  void _handleStatusUpdate(Map<String, dynamic>? data) {
    if (data == null) return;

    final status = data['status'] as String?;
    final message = data['message'] as String?;

    VpnState newState = VpnState.disconnected;
    switch (status) {
      case 'connected':
        newState = VpnState.connected;
        break;
      case 'connecting':
        newState = VpnState.connecting;
        break;
      case 'disconnecting':
        newState = VpnState.disconnecting;
        break;
      case 'error':
        newState = VpnState.error;
        if (message != null) {
          _errorController.add(message);
        }
        break;
      default:
        newState = VpnState.disconnected;
    }

    currentStatus = currentStatus.copyWith(
      state: newState,
      errorMessage: message,
    );

    _statusController.add(currentStatus);
  }

  void _handleTrafficUpdate(Map<String, dynamic>? data) {
    if (data == null) return;

    final upload = (data['upload'] as num?)?.toInt() ?? 0;
    final download = (data['download'] as num?)?.toInt() ?? 0;

    currentStatus = currentStatus.copyWith(
      uploadBytes: upload,
      downloadBytes: download,
    );

    final trafficStats = TrafficStats(
      uploadBytes: upload,
      downloadBytes: download,
      timestamp: DateTime.now(),
    );

    _trafficController.add(trafficStats);
    _statusController.add(currentStatus);
  }

  Future<bool> requestVpnPermission() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('requestVpnPermission');
      return result ?? false;
    } on PlatformException catch (e) {
      _errorController.add('VPN permission request failed: ${e.message}');
      return false;
    }
  }

  Future<bool> connectVpn(ServerConfig config) async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('connectVpn', {
        'server_address': config.serverAddress,
        'server_port': config.port,
        'uuid': config.uuid,
        'public_key': config.publicKey,
        'short_id': config.shortId,
        'sni': config.sni,
        'flow': config.flow,
        'fingerprint': config.fingerprint,
        'encryption': config.encryption,
      });
      
      if (result == true) {
        currentStatus = currentStatus.copyWith(
          state: VpnState.connecting,
          serverName: config.name,
          serverAddress: config.serverAddress,
          port: config.port,
        );
        _statusController.add(currentStatus);
      }
      
      return result ?? false;
    } on PlatformException catch (e) {
      _errorController.add('VPN connection failed: ${e.message}');
      return false;
    }
  }

  Future<bool> disconnectVpn() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('disconnectVpn');
      
      if (result == true) {
        currentStatus = currentStatus.copyWith(
          state: VpnState.disconnecting,
        );
        _statusController.add(currentStatus);
      }
      
      return result ?? false;
    } on PlatformException catch (e) {
      _errorController.add('VPN disconnection failed: ${e.message}');
      return false;
    }
  }

  Future<Map<String, dynamic>> getVpnStatus() async {
    try {
      final result = await _methodChannel.invokeMethod<Map>('getVpnStatus');
      return result ?? {};
    } on PlatformException catch (e) {
      _errorController.add('Failed to get VPN status: ${e.message}');
      return {};
    }
  }

  Future<bool> updateVpnConfig(ServerConfig config) async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('updateVpnConfig', {
        'server_address': config.serverAddress,
        'server_port': config.port,
        'uuid': config.uuid,
        'public_key': config.publicKey,
        'short_id': config.shortId,
        'sni': config.sni,
        'flow': config.flow,
        'fingerprint': config.fingerprint,
        'encryption': config.encryption,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      _errorController.add('Failed to update VPN config: ${e.message}');
      return false;
    }
  }

  Future<bool> setAllowedApps(List<AppInfo> allowedApps) async {
    try {
      final allowedPackages = allowedApps.map((app) => app.packageName).toList();
      final result = await _methodChannel.invokeMethod<bool>('setAllowedApps', {
        'allowed_apps': allowedPackages,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      _errorController.add('Failed to set allowed apps: ${e.message}');
      return false;
    }
  }

  Future<List<AppInfo>> getInstalledApps() async {
    try {
      // This would need to be implemented in the native Android code
      // For now, return empty list
      return [];
    } catch (e) {
      _errorController.add('Failed to get installed apps: ${e.toString()}');
      return [];
    }
  }

  void dispose() {
    _statusController.close();
    _trafficController.close();
    _errorController.close();
  }
}