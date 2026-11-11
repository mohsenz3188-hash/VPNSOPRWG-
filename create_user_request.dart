class CreateUserRequest {
  final String username;
  final String password;
  final int dataLimitGb;

  const CreateUserRequest({
    required this.username,
    required this.password,
    required this.dataLimitGb,
  });

  int get dataLimitBytes => dataLimitGb * 1024 * 1024 * 1024;

  Map<String, dynamic> toJson() {
    return {
      'username': username.trim(),
      'password': password,
      'protocol': 'wireguard',
      'data_limit': dataLimitBytes,
      'data_limit_gb': dataLimitGb,
      'status': 'active',
      'inbounds': {
        'wireguard': ['WG_MAIN_INBOUND'],
      },
    };
  }
}
