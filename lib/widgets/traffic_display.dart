import 'package:flutter/material.dart';
import '../models/traffic_stats.dart';
import '../theme/app_theme.dart';
import 'neon_card_stub.dart';
import 'dart:math' as math;
import 'dart:async';

class TrafficDisplay extends StatelessWidget {
  final int uploadBytes;
  final int downloadBytes;
  final bool showDetails;
  final double height;

  const TrafficDisplay({
    super.key,
    required this.uploadBytes,
    required this.downloadBytes,
    this.showDetails = true,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    final uploadFormatted = _formatBytes(uploadBytes);
    final downloadFormatted = _formatBytes(downloadBytes);
    final totalFormatted = _formatBytes(uploadBytes + downloadBytes);

    return SizedBox(
      height: height,
      child: NeonCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showDetails) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTrafficItem(Icons.upload, 'Upload', uploadFormatted, AppTheme.primaryColor),
                  _buildTrafficItem(Icons.download, 'Download', downloadFormatted, AppTheme.secondaryColor),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: AppTheme.borderColor, height: 1),
              const SizedBox(height: 16),
              _buildTrafficItem(Icons.data_usage, 'Total', totalFormatted, AppTheme.accentColor),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSimpleTrafficItem(Icons.upload, uploadFormatted, AppTheme.primaryColor),
                  const SizedBox(width: 24),
                  _buildSimpleTrafficItem(Icons.download, downloadFormatted, AppTheme.secondaryColor),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrafficItem(IconData icon, String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.neonSecondary.copyWith(color: AppTheme.secondaryTextColor),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.neonTitle.copyWith(
            fontSize: 18,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleTrafficItem(IconData icon, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.neonTitle.copyWith(
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

class AnimatedTrafficBar extends StatelessWidget {
  final double uploadProgress;
  final double downloadProgress;
  final Color uploadColor;
  final Color downloadColor;

  const AnimatedTrafficBar({
    super.key,
    required this.uploadProgress,
    required this.downloadProgress,
    this.uploadColor = AppTheme.primaryColor,
    this.downloadColor = AppTheme.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Network Activity',
            style: AppTheme.neonSecondary,
          ),
          const SizedBox(height: 12),
          _buildProgressBar('Upload', uploadProgress, uploadColor),
          const SizedBox(height: 8),
          _buildProgressBar('Download', downloadProgress, downloadColor),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTheme.neonSecondary.copyWith(color: AppTheme.secondaryTextColor),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: AppTheme.neonSecondary.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: AppTheme.borderColor,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

class TrafficHistoryChart extends StatelessWidget {
  final List<TrafficStats> hourlyStats;
  final List<TrafficStats> dailyStats;
  final bool isHourly;

  const TrafficHistoryChart({
    super.key,
    required this.hourlyStats,
    required this.dailyStats,
    this.isHourly = true,
  });

  @override
  Widget build(BuildContext context) {
    final stats = isHourly ? hourlyStats : dailyStats;
    final maxValue = stats.isNotEmpty ? stats.map((s) => s.uploadBytes + s.downloadBytes).reduce(math.max) : 1;
    
    return NeonCard(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isHourly ? 'Hourly Usage' : 'Daily Usage',
                style: AppTheme.neonSubtitle,
              ),
              Text(
                'Last 24 ${isHourly ? 'Hours' : 'Days'}',
                style: AppTheme.neonSecondary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (stats.isNotEmpty) ...[
            _buildChart(stats, maxValue),
          ] else ...[
            Center(
              child: Text(
                'No data available',
                style: AppTheme.neonSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChart(List<TrafficStats> stats, int maxValue) {
    return SizedBox(
      height: 120,
      child: Row(
        children: stats.take(24).map((stat) {
          final value = stat.uploadBytes + stat.downloadBytes;
          final height = (value / maxValue) * 100;
          
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: math.max(height, 10),
                    decoration: BoxDecoration(
                      gradient: AppTheme.cyanGradient,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isHourly ? '${stat.timestamp.hour}h' : '${stat.timestamp.day}',
                    style: AppTheme.neonSecondary.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class RealTimeTrafficMonitor extends StatefulWidget {
  final Stream<TrafficStats> trafficStream;
  final Duration updateInterval;

  const RealTimeTrafficMonitor({
    super.key,
    required this.trafficStream,
    this.updateInterval = const Duration(seconds: 1),
  });

  @override
  _RealTimeTrafficMonitorState createState() => _RealTimeTrafficMonitorState();
}

class _RealTimeTrafficMonitorState extends State<RealTimeTrafficMonitor> {
  late StreamSubscription<TrafficStats> _subscription;
  int _currentUpload = 0;
  int _currentDownload = 0;
  int _lastUpload = 0;
  int _lastDownload = 0;
  DateTime _lastUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _subscription = widget.trafficStream.listen((stats) {
      final now = DateTime.now();
      final duration = now.difference(_lastUpdate).inSeconds;
      
      if (duration > 0) {
        final uploadSpeed = (stats.uploadBytes - _lastUpload) ~/ duration;
        final downloadSpeed = (stats.downloadBytes - _lastDownload) ~/ duration;
        
        setState(() {
          _currentUpload = uploadSpeed;
          _currentDownload = downloadSpeed;
          _lastUpload = stats.uploadBytes;
          _lastDownload = stats.downloadBytes;
          _lastUpdate = now;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TrafficDisplay(
      uploadBytes: _currentUpload,
      downloadBytes: _currentDownload,
      showDetails: true,
      height: 160,
    );
  }
}