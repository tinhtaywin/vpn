enum VpnState {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error
}

class VpnStatus {
  final VpnState state;
  final String serverName;
  final String serverAddress;
  final int port;
  final int uploadBytes;
  final int downloadBytes;
  final DateTime? connectedAt;
  final String? errorMessage;

  VpnStatus({
    required this.state,
    this.serverName = '',
    this.serverAddress = '',
    this.port = 0,
    this.uploadBytes = 0,
    this.downloadBytes = 0,
    this.connectedAt,
    this.errorMessage,
  });

  VpnStatus copyWith({
    VpnState? state,
    String? serverName,
    String? serverAddress,
    int? port,
    int? uploadBytes,
    int? downloadBytes,
    DateTime? connectedAt,
    String? errorMessage,
  }) {
    return VpnStatus(
      state: state ?? this.state,
      serverName: serverName ?? this.serverName,
      serverAddress: serverAddress ?? this.serverAddress,
      port: port ?? this.port,
      uploadBytes: uploadBytes ?? this.uploadBytes,
      downloadBytes: downloadBytes ?? this.downloadBytes,
      connectedAt: connectedAt ?? this.connectedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  String get displaySpeed {
    final uploadSpeed = formatBytes(uploadBytes);
    final downloadSpeed = formatBytes(downloadBytes);
    return '$uploadSpeed ↑ / $downloadSpeed ↓';
  }

  String get connectionTime {
    if (connectedAt == null) return 'Not connected';
    
    final now = DateTime.now();
    final diff = now.difference(connectedAt!);
    
    if (diff.inHours > 0) {
      return '${diff.inHours}h ${diff.inMinutes % 60}m';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ${diff.inSeconds % 60}s';
    } else {
      return '${diff.inSeconds}s';
    }
  }

  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  String toString() {
    return 'VpnStatus(state: $state, serverName: $serverName, serverAddress: $serverAddress, port: $port, uploadBytes: $uploadBytes, downloadBytes: $downloadBytes, connectedAt: $connectedAt, errorMessage: $errorMessage)';
  }
}