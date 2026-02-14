import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_info.dart';
import '../models/traffic_history.dart';
import '../models/traffic_stats.dart';
import '../models/server_config.dart';

class StorageService {
  static const String _keyServerConfigs = 'server_configs';
  static const String _keyCurrentServer = 'current_server';
  static const String _keyAllowedApps = 'allowed_apps';
  static const String _keySettings = 'settings';
  static const String _keyTrafficHistory = 'traffic_history';

  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // Server Config Management
  Future<void> saveServerConfigs(List<ServerConfig> configs) async {
    final prefs = await _getPrefs();
    final jsonList = configs.map((config) => config.toJson()).toList();
    await prefs.setString(_keyServerConfigs, jsonEncode(jsonList));
  }

  Future<List<ServerConfig>> getServerConfigs() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_keyServerConfigs);
    
    if (jsonString == null) {
      return [];
    }
    
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((json) => ServerConfig.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error parsing server configs: $e');
      return [];
    }
  }

  Future<void> saveCurrentServer(ServerConfig config) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyCurrentServer, jsonEncode(config.toJson()));
  }

  Future<ServerConfig?> getCurrentServer() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_keyCurrentServer);
    
    if (jsonString == null) {
      return null;
    }
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return ServerConfig.fromJson(json);
    } catch (e) {
      print('Error parsing current server: $e');
      return null;
    }
  }

  Future<void> deleteServerConfig(String serverAddress) async {
    final configs = await getServerConfigs();
    final filteredConfigs = configs.where((config) => config.serverAddress != serverAddress).toList();
    await saveServerConfigs(filteredConfigs);
  }

  // App Selection Management
  Future<void> saveAllowedApps(List<AppInfo> apps) async {
    final prefs = await _getPrefs();
    final jsonList = apps.map((app) => app.toJson()).toList();
    await prefs.setString(_keyAllowedApps, jsonEncode(jsonList));
  }

  Future<List<AppInfo>> getAllowedApps() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_keyAllowedApps);
    
    if (jsonString == null) {
      return [];
    }
    
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList.map((json) => AppInfo.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error parsing allowed apps: $e');
      return [];
    }
  }

  // Settings Management
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keySettings, jsonEncode(settings));
  }

  Future<Map<String, dynamic>> getSettings() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_keySettings);
    
    if (jsonString == null) {
      return {
        'autoConnect': false,
        'killSwitch': false,
        'customDns': '',
        'theme': 'neon',
        'splitTunneling': true,
        'bypassMode': false,
      };
    }
    
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error parsing settings: $e');
      return {
        'autoConnect': false,
        'killSwitch': false,
        'customDns': '',
        'theme': 'neon',
        'splitTunneling': true,
        'bypassMode': false,
      };
    }
  }

  Future<void> setAutoConnect(bool enabled) async {
    final settings = await getSettings();
    settings['autoConnect'] = enabled;
    await saveSettings(settings);
  }

  Future<bool> getAutoConnect() async {
    final settings = await getSettings();
    return settings['autoConnect'] as bool? ?? false;
  }

  Future<void> setKillSwitch(bool enabled) async {
    final settings = await getSettings();
    settings['killSwitch'] = enabled;
    await saveSettings(settings);
  }

  Future<bool> getKillSwitch() async {
    final settings = await getSettings();
    return settings['killSwitch'] as bool? ?? false;
  }

  Future<void> setCustomDns(String dns) async {
    final settings = await getSettings();
    settings['customDns'] = dns;
    await saveSettings(settings);
  }

  Future<String> getCustomDns() async {
    final settings = await getSettings();
    return settings['customDns'] as String? ?? '';
  }

  Future<void> setSplitTunneling(bool enabled) async {
    final settings = await getSettings();
    settings['splitTunneling'] = enabled;
    await saveSettings(settings);
  }

  Future<bool> getSplitTunneling() async {
    final settings = await getSettings();
    return settings['splitTunneling'] as bool? ?? true;
  }

  Future<void> setBypassMode(bool enabled) async {
    final settings = await getSettings();
    settings['bypassMode'] = enabled;
    await saveSettings(settings);
  }

  Future<bool> getBypassMode() async {
    final settings = await getSettings();
    return settings['bypassMode'] as bool? ?? false;
  }

  // Traffic History Management
  Future<void> saveTrafficHistory(TrafficHistory history) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyTrafficHistory, jsonEncode(history.toJson()));
  }

  Future<TrafficHistory> getTrafficHistory() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_keyTrafficHistory);
    
    if (jsonString == null) {
      return TrafficHistory.empty();
    }
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return TrafficHistory.fromJson(json);
    } catch (e) {
      print('Error parsing traffic history: $e');
      return TrafficHistory.empty();
    }
  }

  Future<void> addTrafficStats(TrafficStats stats) async {
    final history = await getTrafficHistory();
    final updatedHourly = List<TrafficStats>.from(history.hourlyStats)..add(stats);
    final updatedHistory = history.copyWith(hourlyStats: updatedHourly);
    await saveTrafficHistory(updatedHistory);
  }

  // Utility Methods
  Future<void> clearAllData() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }

  Future<void> resetToDefaults() async {
    await clearAllData();
    
    // Create default server config
    final defaultServer = ServerConfig(
      serverAddress: 'example.com',
      port: 443,
      uuid: '00000000-0000-0000-0000-000000000000',
      name: 'Default Server',
    );
    
    await saveServerConfigs([defaultServer]);
    await saveCurrentServer(defaultServer);
  }
}