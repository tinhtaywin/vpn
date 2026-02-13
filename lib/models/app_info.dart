class AppInfo {
  final String packageName;
  final String appName;
  final String? versionName;
  final int? versionCode;
  final bool isSystemApp;
  final bool isSelected;
  final String? iconPath;

  AppInfo({
    required this.packageName,
    required this.appName,
    this.versionName,
    this.versionCode,
    this.isSystemApp = false,
    this.isSelected = false,
    this.iconPath,
  });

  AppInfo copyWith({
    String? packageName,
    String? appName,
    String? versionName,
    int? versionCode,
    bool? isSystemApp,
    bool? isSelected,
    String? iconPath,
  }) {
    return AppInfo(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      versionName: versionName ?? this.versionName,
      versionCode: versionCode ?? this.versionCode,
      isSystemApp: isSystemApp ?? this.isSystemApp,
      isSelected: isSelected ?? this.isSelected,
      iconPath: iconPath ?? this.iconPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'appName': appName,
      'versionName': versionName,
      'versionCode': versionCode,
      'isSystemApp': isSystemApp,
      'isSelected': isSelected,
      'iconPath': iconPath,
    };
  }

  factory AppInfo.fromJson(Map<String, dynamic> json) {
    return AppInfo(
      packageName: json['packageName'] ?? '',
      appName: json['appName'] ?? '',
      versionName: json['versionName'],
      versionCode: json['versionCode'],
      isSystemApp: json['isSystemApp'] ?? false,
      isSelected: json['isSelected'] ?? false,
      iconPath: json['iconPath'],
    );
  }

  @override
  String toString() {
    return 'AppInfo(packageName: $packageName, appName: $appName, versionName: $versionName, versionCode: $versionCode, isSystemApp: $isSystemApp, isSelected: $isSelected, iconPath: $iconPath)';
  }
}