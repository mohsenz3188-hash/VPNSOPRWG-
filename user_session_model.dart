class UserSessionModel {
  final String username;
  final String accessToken;
  final String wgQuickConfig;
  final String serverEndpoint;
  final int dataLimitBytes;
  final int dataUsedBytes;
  final bool isActive;

  const UserSessionModel({
    required this.username,
    required this.accessToken,
    required this.wgQuickConfig,
    required this.serverEndpoint,
    required this.dataLimitBytes,
    required this.dataUsedBytes,
    required this.isActive,
  });

  int get remainingBytes =>
      (dataLimitBytes - dataUsedBytes).clamp(0, dataLimitBytes);

  double get remainingGb => remainingBytes / (1024 * 1024 * 1024);
  double get totalGb => dataLimitBytes / (1024 * 1024 * 1024);
  double get usedGb => dataUsedBytes / (1024 * 1024 * 1024);

  double get usageRatio =>
      dataLimitBytes > 0 ? (dataUsedBytes / dataLimitBytes).clamp(0.0, 1.0) : 0.0;

  factory UserSessionModel.fromJson(Map<String, dynamic> json, {String? fallbackToken}) {
    final String rawWgConfig = (json['wireguard_config'] ?? json['wg_config'] ?? '') as String;
    final String endpoint = (json['server_endpoint'] ??
            _extractEndpointFromWgConfig(rawWgConfig) ??
            '127.0.0.1:51820')
        .toString();

    return UserSessionModel(
      username: (json['username'] ?? '') as String,
      accessToken: (json['access_token'] ?? fallbackToken ?? '') as String,
      wgQuickConfig: rawWgConfig,
      serverEndpoint: endpoint,
      dataLimitBytes: (json['data_limit_bytes'] ?? json['data_limit'] ?? 0) as int,
      dataUsedBytes: (json['data_used_bytes'] ?? json['used_traffic'] ?? 0) as int,
      isActive: (json['status'] ?? 'active') == 'active',
    );
  }

  static String? _extractEndpointFromWgConfig(String config) {
    final RegExp regex = RegExp(r'Endpoint\s*=\s*([^\s\r\n]+)', caseSensitive: false);
    final match = regex.firstMatch(config);
    return match?.group(1);
  }
}
