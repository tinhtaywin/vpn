
class TrafficStats {
  final int totalUploadBytes;
  final int totalDownloadBytes;
  final int currentUploadBytes;
  final int currentDownloadBytes;
  final DateTime startTime;
  final DateTime lastUpdate;
  final int uploadBytes;
  final int downloadBytes;
  final DateTime timestamp;

  TrafficStats({
    required this.totalUploadBytes,
    required this.totalDownloadBytes,
    required this.currentUploadBytes,
    required this.currentDownloadBytes,
    required this.startTime,
    required this.lastUpdate,
    required this.uploadBytes,
    required this.downloadBytes,
    required this.timestamp,
  });

  factory TrafficStats.fromJson(Map<String, dynamic> json) {
    return TrafficStats(
      totalUploadBytes: json['totalUploadBytes'] ?? 0,
      totalDownloadBytes: json['totalDownloadBytes'] ?? 0,
      currentUploadBytes: json['currentUploadBytes'] ?? 0,
      currentDownloadBytes: json['currentDownloadBytes'] ?? 0,
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime']),
      lastUpdate: DateTime.fromMillisecondsSinceEpoch(json['lastUpdate']),
      uploadBytes: json['uploadBytes'] ?? 0,
      downloadBytes: json['downloadBytes'] ?? 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUploadBytes': totalUploadBytes,
      'totalDownloadBytes': totalDownloadBytes,
      'currentUploadBytes': currentUploadBytes,
      'currentDownloadBytes': currentDownloadBytes,
      'startTime': startTime.millisecondsSinceEpoch,
      'lastUpdate': lastUpdate.millisecondsSinceEpoch,
      'uploadBytes': uploadBytes,
      'downloadBytes': downloadBytes,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  TrafficStats copyWith({
    int? totalUploadBytes,
    int? totalDownloadBytes,
    int? currentUploadBytes,
    int? currentDownloadBytes,
    DateTime? startTime,
    DateTime? lastUpdate,
    int? uploadBytes,
    int? downloadBytes,
    DateTime? timestamp,
  }) {
    return TrafficStats(
      totalUploadBytes: totalUploadBytes ?? this.totalUploadBytes,
      totalDownloadBytes: totalDownloadBytes ?? this.totalDownloadBytes,
      currentUploadBytes: currentUploadBytes ?? this.currentUploadBytes,
      currentDownloadBytes: currentDownloadBytes ?? this.currentDownloadBytes,
      startTime: startTime ?? this.startTime,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      uploadBytes: uploadBytes ?? this.uploadBytes,
      downloadBytes: downloadBytes ?? this.downloadBytes,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  int get totalTrafficBytes => totalUploadBytes + totalDownloadBytes;
  int get currentTrafficBytes => currentUploadBytes + currentDownloadBytes;

  @override
  String toString() {
    return 'TrafficStats{totalUploadBytes: $totalUploadBytes, totalDownloadBytes: $totalDownloadBytes, currentUploadBytes: $currentUploadBytes, currentDownloadBytes: $currentDownloadBytes, startTime: $startTime, lastUpdate: $lastUpdate}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is TrafficStats &&
           other.totalUploadBytes == totalUploadBytes &&
           other.totalDownloadBytes == totalDownloadBytes &&
           other.currentUploadBytes == currentUploadBytes &&
           other.currentDownloadBytes == currentDownloadBytes &&
           other.startTime == startTime &&
           other.lastUpdate == lastUpdate &&
           other.uploadBytes == uploadBytes &&
           other.downloadBytes == downloadBytes &&
           other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return totalUploadBytes.hashCode ^
           totalDownloadBytes.hashCode ^
           currentUploadBytes.hashCode ^
           currentDownloadBytes.hashCode ^
           startTime.hashCode ^
           lastUpdate.hashCode ^
           uploadBytes.hashCode ^
           downloadBytes.hashCode ^
           timestamp.hashCode;
  }
}