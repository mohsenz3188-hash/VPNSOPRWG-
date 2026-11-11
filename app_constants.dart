class AppConstants {
  AppConstants._();

  /// Base URL of your Pasargad Panel REST API
  static const String baseUrl = 'https://panel.pasargad-vpn.example.com/api/v1';

  /// Admin Panel API Master Token / Key for administrative REST operations
  static const String panelAdminApiKey = 'PASARGAD_PANEL_ADMIN_SECRET_BEARER_KEY';

  /// Hardcoded Strong Admin Password as specified in requirements
  static const String adminMasterPassword = r'P@s$w0rd_Admin_Pasargad!2026#X';

  /// WireGuard Native Interface Name
  static const String wgInterfaceName = 'wg_pasargad0';

  /// Secure Storage Keys
  static const String keyClientUsername = 'pasargad_client_username';
  static const String keyClientPassword = 'pasargad_client_password';
  static const String keyClientAccessToken = 'pasargad_client_jwt_token';
  static const String keyCachedWgConfig = 'pasargad_cached_wg_conf';
  static const String keyCachedServerAddress = 'pasargad_cached_endpoint';
}
