import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  
  // Request VPN permission
  Future<bool> requestVpnPermission() async {
    try {
      // VPN permission is handled by the Android system
      // We just need to check if it's granted
      final status = await Permission.vpn.status;
      
      if (status.isGranted) {
        return true;
      } else if (status.isDenied) {
        // Request permission
        final result = await Permission.vpn.request();
        return result.isGranted;
      } else if (status.isPermanentlyDenied) {
        // Permission is permanently denied, open app settings
        openAppSettings();
        return false;
      }
      
      return false;
    } catch (e) {
      print('Error requesting VPN permission: $e');
      return false;
    }
  }

  // Request storage permissions for file operations
  Future<bool> requestStoragePermissions() async {
    try {
      final status = await Permission.storage.status;
      
      if (status.isGranted) {
        return true;
      } else {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
    } catch (e) {
      print('Error requesting storage permissions: $e');
      return false;
    }
  }

  // Request network state permissions
  Future<bool> requestNetworkPermissions() async {
    try {
      final wifiStatus = await Permission.accessWifiState.status;
      final networkStatus = await Permission.accessNetworkState.status;
      
      bool wifiGranted = wifiStatus.isGranted;
      bool networkGranted = networkStatus.isGranted;
      
      if (!wifiGranted) {
        final wifiResult = await Permission.accessWifiState.request();
        wifiGranted = wifiResult.isGranted;
      }
      
      if (!networkGranted) {
        final networkResult = await Permission.accessNetworkState.request();
        networkGranted = networkResult.isGranted;
      }
      
      return wifiGranted && networkGranted;
    } catch (e) {
      print('Error requesting network permissions: $e');
      return false;
    }
  }

  // Check if all required permissions are granted
  Future<bool> checkAllPermissions() async {
    try {
      final vpnStatus = await Permission.vpn.status;
      final storageStatus = await Permission.storage.status;
      final wifiStatus = await Permission.accessWifiState.status;
      final networkStatus = await Permission.accessNetworkState.status;
      
      return vpnStatus.isGranted && 
             storageStatus.isGranted && 
             wifiStatus.isGranted && 
             networkStatus.isGranted;
    } catch (e) {
      print('Error checking permissions: $e');
      return false;
    }
  }

  // Request all required permissions
  Future<Map<String, bool>> requestAllPermissions() async {
    final results = <String, bool>{};
    
    try {
      // Request VPN permission
      results['vpn'] = await requestVpnPermission();
      
      // Request storage permission
      results['storage'] = await requestStoragePermissions();
      
      // Request network permissions
      results['network'] = await requestNetworkPermissions();
      
    } catch (e) {
      print('Error requesting permissions: $e');
      results['vpn'] = false;
      results['storage'] = false;
      results['network'] = false;
    }
    
    return results;
  }

  // Check if a specific permission is granted
  Future<bool> isPermissionGranted(Permission permission) async {
    try {
      final status = await permission.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking permission: $e');
      return false;
    }
  }

  // Open app settings to allow user to grant permissions manually
  Future<void> openAppSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      print('Error opening app settings: $e');
    }
  }

  // Get permission status for display purposes
  Future<Map<String, PermissionStatus>> getPermissionStatuses() async {
    final statuses = <String, PermissionStatus>{};
    
    try {
      statuses['vpn'] = await Permission.vpn.status;
      statuses['storage'] = await Permission.storage.status;
      statuses['wifi'] = await Permission.accessWifiState.status;
      statuses['network'] = await Permission.accessNetworkState.status;
    } catch (e) {
      print('Error getting permission statuses: $e');
    }
    
    return statuses;
  }
}