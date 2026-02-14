import 'package:flutter/material.dart';
import '../models/traffic_history.dart';
import '../services/storage_service.dart';

class SettingsProvider with ChangeNotifier {
  final StorageService _storageService;

  Map<String, dynamic> _settings = {};
  bool _isLoading = false;
  String _errorMessage = '';

  SettingsProvider(this._storageService) {
    _loadSettings();
  }

  Map<String, dynamic> get settings => _settings;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  bool get autoConnect => _settings['autoConnect'] as bool? ?? false;
  bool get killSwitch => _settings['killSwitch'] as bool? ?? false;
  String get customDns => _settings['customDns'] as String? ?? '';
  String get theme => _settings['theme'] as String? ?? 'neon';
  bool get splitTunneling => _settings['splitTunneling'] as bool? ?? true;
  bool get bypassMode => _settings['bypassMode'] as bool? ?? false;

  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _settings = await _storageService.getSettings();
    } catch (e) {
      _errorMessage = 'Failed to load settings: $e';
      print('Error loading settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setAutoConnect(bool enabled) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storageService.setAutoConnect(enabled);
      _settings['autoConnect'] = enabled;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to update auto-connect setting: $e';
      print('Error updating auto-connect: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setKillSwitch(bool enabled) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storageService.setKillSwitch(enabled);
      _settings['killSwitch'] = enabled;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to update kill switch setting: $e';
      print('Error updating kill switch: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setCustomDns(String dns) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storageService.setCustomDns(dns);
      _settings['customDns'] = dns;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to update custom DNS setting: $e';
      print('Error updating custom DNS: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setTheme(String themeName) async {
    _isLoading = true;
    notifyListeners();

    try {
      _settings['theme'] = themeName;
      await _storageService.saveSettings(_settings);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to update theme setting: $e';
      print('Error updating theme: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setSplitTunneling(bool enabled) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storageService.setSplitTunneling(enabled);
      _settings['splitTunneling'] = enabled;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to update split tunneling setting: $e';
      print('Error updating split tunneling: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setBypassMode(bool enabled) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storageService.setBypassMode(enabled);
      _settings['bypassMode'] = enabled;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to update bypass mode setting: $e';
      print('Error updating bypass mode: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetToDefaults() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storageService.resetToDefaults();
      await _loadSettings();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to reset settings: $e';
      print('Error resetting settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearCache() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Clear traffic history
      await _storageService.saveTrafficHistory(TrafficHistory.empty());
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to clear cache: $e';
      print('Error clearing cache: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storageService.clearAllData();
      await _loadSettings();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to clear all data: $e';
      print('Error clearing all data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSettings(Map<String, dynamic> newSettings) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storageService.saveSettings(newSettings);
      _settings = newSettings;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to update settings: $e';
      print('Error updating settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearError() async {
    _errorMessage = '';
    notifyListeners();
  }
}