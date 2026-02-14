import 'dart:typed_data';

class AppInfo {
  final String appName;
  final String packageName;
  final String? versionName;
  final int? versionCode;
  final bool isSystemApp;
  final String? iconPath;
  final Uint8List? iconData;
  final String? appPath;
  final bool isSelected;

  AppInfo({
    required this.appName,
    required this.packageName,
    this.versionName,
    this.versionCode,
    this.isSystemApp = false,
    this.iconPath,
    this.iconData,
    this.appPath,
    this.isSelected = false,
  });

  factory AppInfo.fromJson(Map<String, dynamic> json) {
    return AppInfo(
      appName: json['appName'] ?? '',
      packageName: json['packageName'] ?? '',
      versionName: json['versionName'],
      versionCode: json['versionCode'],
      isSystemApp: json['isSystemApp'] ?? false,
      iconPath: json['iconPath'],
      iconData: json['iconData'] != null ? Uint8List.fromList(json['iconData']) : null,
      appPath: json['appPath'],
      isSelected: json['isSelected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'packageName': packageName,
      'versionName': versionName,
      'versionCode': versionCode,
      'isSystemApp': isSystemApp,
      'iconPath': iconPath,
      'iconData': iconData?.toList(),
      'appPath': appPath,
      'isSelected': isSelected,
    };
  }

  AppInfo copyWith({
    String? appName,
    String? packageName,
    String? versionName,
    int? versionCode,
    bool? isSystemApp,
    String? iconPath,
    Uint8List? iconData,
    String? appPath,
    bool? isSelected,
  }) {
    return AppInfo(
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      versionName: versionName ?? this.versionName,
      versionCode: versionCode ?? this.versionCode,
      isSystemApp: isSystemApp ?? this.isSystemApp,
      iconPath: iconPath ?? this.iconPath,
      iconData: iconData ?? this.iconData,
      appPath: appPath ?? this.appPath,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  String toString() {
    return 'AppInfo{appName: $appName, packageName: $packageName, versionName: $versionName, versionCode: $versionCode, isSystemApp: $isSystemApp, iconPath: $iconPath, appPath: $appPath}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is AppInfo &&
           other.appName == appName &&
           other.packageName == packageName &&
           other.versionName == versionName &&
           other.versionCode == versionCode &&
           other.isSystemApp == isSystemApp &&
           other.iconPath == iconPath &&
           other.appPath == appPath &&
           other.isSelected == isSelected;
  }

  @override
  int get hashCode {
    return appName.hashCode ^
           packageName.hashCode ^
           versionName.hashCode ^
           versionCode.hashCode ^
           isSystemApp.hashCode ^
           iconPath.hashCode ^
           appPath.hashCode ^
           isSelected.hashCode;
  }
}