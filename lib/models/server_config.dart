class ServerConfig {
  final String serverAddress;
  final int port;
  final String uuid;
  final String flow;
  final String encryption;
  final String publicKey;
  final String shortId;
  final String sni;
  final String fingerprint;
  final String spiderX;
  final String name;

  ServerConfig({
    required this.serverAddress,
    required this.port,
    required this.uuid,
    this.flow = 'none',
    this.encryption = 'none',
    this.publicKey = '',
    this.shortId = '',
    this.sni = '',
    this.fingerprint = 'chrome',
    this.spiderX = '',
    this.name = 'Default Server',
  });

  Map<String, dynamic> toJson() {
    return {
      'serverAddress': serverAddress,
      'port': port,
      'uuid': uuid,
      'flow': flow,
      'encryption': encryption,
      'publicKey': publicKey,
      'shortId': shortId,
      'sni': sni,
      'fingerprint': fingerprint,
      'spiderX': spiderX,
      'name': name,
    };
  }

  factory ServerConfig.fromJson(Map<String, dynamic> json) {
    return ServerConfig(
      serverAddress: json['serverAddress'] ?? '',
      port: json['port'] ?? 443,
      uuid: json['uuid'] ?? '',
      flow: json['flow'] ?? 'none',
      encryption: json['encryption'] ?? 'none',
      publicKey: json['publicKey'] ?? '',
      shortId: json['shortId'] ?? '',
      sni: json['sni'] ?? '',
      fingerprint: json['fingerprint'] ?? 'chrome',
      spiderX: json['spiderX'] ?? '',
      name: json['name'] ?? 'Default Server',
    );
  }

  ServerConfig copyWith({
    String? serverAddress,
    int? port,
    String? uuid,
    String? flow,
    String? encryption,
    String? publicKey,
    String? shortId,
    String? sni,
    String? fingerprint,
    String? spiderX,
    String? name,
  }) {
    return ServerConfig(
      serverAddress: serverAddress ?? this.serverAddress,
      port: port ?? this.port,
      uuid: uuid ?? this.uuid,
      flow: flow ?? this.flow,
      encryption: encryption ?? this.encryption,
      publicKey: publicKey ?? this.publicKey,
      shortId: shortId ?? this.shortId,
      sni: sni ?? this.sni,
      fingerprint: fingerprint ?? this.fingerprint,
      spiderX: spiderX ?? this.spiderX,
      name: name ?? this.name,
    );
  }

  @override
  String toString() {
    return 'ServerConfig(serverAddress: $serverAddress, port: $port, uuid: $uuid, flow: $flow, encryption: $encryption, publicKey: $publicKey, shortId: $shortId, sni: $sni, fingerprint: $fingerprint, spiderX: $spiderX, name: $name)';
  }
}