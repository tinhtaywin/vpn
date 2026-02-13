class TrafficStats {
  final int uploadBytes;
  final int downloadBytes;
  final DateTime timestamp;

  TrafficStats({
    required this.uploadBytes,
    required this.downloadBytes,
    required this.timestamp,
  });

  TrafficStats copyWith({
    int? uploadBytes,
    int? downloadBytes,
    DateTime? timestamp,
  }) {
    return TrafficStats(
      uploadBytes: uploadBytes ?? this.uploadBytes,
      downloadBytes: downloadBytes ?? this.downloadBytes,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  String get uploadFormatted => formatBytes(uploadBytes);
  String get downloadFormatted => formatBytes(downloadBytes);
  String get totalFormatted => formatBytes(uploadBytes + downloadBytes);

  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  Map<String, dynamic> toJson() {
    return {
      'uploadBytes': uploadBytes,
      'downloadBytes': downloadBytes,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TrafficStats.fromJson(Map<String, dynamic> json) {
    return TrafficStats(
      uploadBytes: json['uploadBytes'] ?? 0,
      downloadBytes: json['downloadBytes'] ?? 0,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  String toString() {
    return 'TrafficStats(uploadBytes: $uploadBytes, downloadBytes: $downloadBytes, timestamp: $timestamp)';
  }
}

class TrafficHistory {
  final List<TrafficStats> hourlyStats;
  final List<TrafficStats> dailyStats;

  TrafficHistory({
    required this.hourlyStats,
    required this.dailyStats,
  });

  TrafficHistory copyWith({
    List<TrafficStats>? hourlyStats,
    List<TrafficStats>? dailyStats,
  }) {
    return TrafficHistory(
      hourlyStats: hourlyStats ?? this.hourlyStats,
      dailyStats: dailyStats ?? this.dailyStats,
    );
  }

  factory TrafficHistory.empty() {
    return TrafficHistory(
      hourlyStats: [],
      dailyStats: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hourlyStats': hourlyStats.map((stat) => stat.toJson()).toList(),
      'dailyStats': dailyStats.map((stat) => stat.toJson()).toList(),
    };
  }

  factory TrafficHistory.fromJson(Map<String, dynamic> json) {
    return TrafficHistory(
      hourlyStats: (json['hourlyStats'] as List?)
              ?.map((e) => TrafficStats.fromJson(e))
              .toList() ??
          [],
      dailyStats: (json['dailyStats'] as List?)
              ?.map((e) => TrafficStats.fromJson(e))
              .toList() ??
          [],
    );
  }

  @override
  String toString() {
    return 'TrafficHistory(hourlyStats: $hourlyStats, dailyStats: $dailyStats)';
  }
}