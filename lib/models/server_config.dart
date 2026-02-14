class ServerConfig {
  final String serverAddress;
  final int port;
  final String uuid;
  final String name;
  final String? publicKey;
  final String? shortId;
  final String? sni;
  final String? spiderX;
  final String? flow;
  final String? encryption;
  final String? fingerprint;

  ServerConfig({
    required this.serverAddress,
    required this.port,
    required this.uuid,
    required this.name,
    this.publicKey,
    this.shortId,
    this.sni,
    this.spiderX,
    this.flow,
    this.encryption,
    this.fingerprint,
  });

  factory ServerConfig.fromJson(Map<String, dynamic> json) {
    return ServerConfig(
      serverAddress: json['serverAddress'] ?? '',
      port: json['port'] ?? 443,
      uuid: json['uuid'] ?? '',
      name: json['name'] ?? 'Unknown Server',
      publicKey: json['publicKey'],
      shortId: json['shortId'],
      sni: json['sni'],
      spiderX: json['spiderX'],
      flow: json['flow'],
      encryption: json['encryption'],
      fingerprint: json['fingerprint'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serverAddress': serverAddress,
      'port': port,
      'uuid': uuid,
      'name': name,
      'publicKey': publicKey,
      'shortId': shortId,
      'sni': sni,
      'spiderX': spiderX,
      'flow': flow,
      'encryption': encryption,
      'fingerprint': fingerprint,
    };
  }

  ServerConfig copyWith({
    String? serverAddress,
    int? port,
    String? uuid,
    String? name,
    String? publicKey,
    String? shortId,
    String? sni,
    String? spiderX,
    String? flow,
    String? encryption,
    String? fingerprint,
  }) {
    return ServerConfig(
      serverAddress: serverAddress ?? this.serverAddress,
      port: port ?? this.port,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      publicKey: publicKey ?? this.publicKey,
      shortId: shortId ?? this.shortId,
      sni: sni ?? this.sni,
      spiderX: spiderX ?? this.spiderX,
      flow: flow ?? this.flow,
      encryption: encryption ?? this.encryption,
      fingerprint: fingerprint ?? this.fingerprint,
    );
  }

  @override
  String toString() {
    return 'ServerConfig{serverAddress: $serverAddress, port: $port, uuid: $uuid, name: $name, publicKey: $publicKey, shortId: $shortId, sni: $sni, spiderX: $spiderX, flow: $flow, encryption: $encryption, fingerprint: $fingerprint}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ServerConfig &&
           other.serverAddress == serverAddress &&
           other.port == port &&
           other.uuid == uuid &&
           other.name == name &&
           other.publicKey == publicKey &&
           other.shortId == shortId &&
           other.sni == sni &&
           other.spiderX == spiderX &&
           other.flow == flow &&
           other.encryption == encryption &&
           other.fingerprint == fingerprint;
  }

  @override
  int get hashCode {
    return serverAddress.hashCode ^
           port.hashCode ^
           uuid.hashCode ^
           name.hashCode ^
           publicKey.hashCode ^
           shortId.hashCode ^
           sni.hashCode ^
           spiderX.hashCode ^
           flow.hashCode ^
           encryption.hashCode ^
           fingerprint.hashCode;
  }
}
