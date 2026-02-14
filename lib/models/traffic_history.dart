import '../models/traffic_stats.dart';

class TrafficHistory {
  final DateTime timestamp;
  final int uploadBytes;
  final int downloadBytes;
  final int totalBytes;
  final List<TrafficStats> hourlyStats;
  final List<TrafficStats> dailyStats;

  TrafficHistory({
    required this.timestamp,
    required this.uploadBytes,
    required this.downloadBytes,
    required this.totalBytes,
    this.hourlyStats = const [],
    this.dailyStats = const [],
  });

  factory TrafficHistory.fromJson(Map<String, dynamic> json) {
    return TrafficHistory(
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      uploadBytes: json['uploadBytes'] ?? 0,
      downloadBytes: json['downloadBytes'] ?? 0,
      totalBytes: json['totalBytes'] ?? 0,
    );
  }

  factory TrafficHistory.empty() {
    return TrafficHistory(
      timestamp: DateTime.now(),
      uploadBytes: 0,
      downloadBytes: 0,
      totalBytes: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'uploadBytes': uploadBytes,
      'downloadBytes': downloadBytes,
      'totalBytes': totalBytes,
    };
  }

  TrafficHistory copyWith({
    DateTime? timestamp,
    int? uploadBytes,
    int? downloadBytes,
    int? totalBytes,
    List<TrafficStats>? hourlyStats,
    List<TrafficStats>? dailyStats,
  }) {
    return TrafficHistory(
      timestamp: timestamp ?? this.timestamp,
      uploadBytes: uploadBytes ?? this.uploadBytes,
      downloadBytes: downloadBytes ?? this.downloadBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      hourlyStats: hourlyStats ?? this.hourlyStats,
      dailyStats: dailyStats ?? this.dailyStats,
    );
  }

  @override
  String toString() {
    return 'TrafficHistory{timestamp: $timestamp, uploadBytes: $uploadBytes, downloadBytes: $downloadBytes, totalBytes: $totalBytes}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is TrafficHistory &&
           other.timestamp == timestamp &&
           other.uploadBytes == uploadBytes &&
           other.downloadBytes == downloadBytes &&
           other.totalBytes == totalBytes;
  }

  @override
  int get hashCode {
    return timestamp.hashCode ^
           uploadBytes.hashCode ^
           downloadBytes.hashCode ^
           totalBytes.hashCode;
  }
}