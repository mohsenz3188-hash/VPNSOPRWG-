import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  Future<void> saveClientSession({
    required String username,
    required String password,
    required String token,
    required String wgConfig,
    required String serverAddress,
  }) async {
    await Future.wait([
      _storage.write(key: AppConstants.keyClientUsername, value: username),
      _storage.write(key: AppConstants.keyClientPassword, value: password),
      _storage.write(key: AppConstants.keyClientAccessToken, value: token),
      _storage.write(key: AppConstants.keyCachedWgConfig, value: wgConfig),
      _storage.write(key: AppConstants.keyCachedServerAddress, value: serverAddress),
    ]);
  }

  Future<Map<String, String?>> getSavedCredentials() async {
    final results = await Future.wait([
      _storage.read(key: AppConstants.keyClientUsername),
      _storage.read(key: AppConstants.keyClientPassword),
      _storage.read(key: AppConstants.keyClientAccessToken),
      _storage.read(key: AppConstants.keyCachedWgConfig),
      _storage.read(key: AppConstants.keyCachedServerAddress),
    ]);

    return {
      'username': results[0],
      'password': results[1],
      'token': results[2],
      'wgConfig': results[3],
      'serverAddress': results[4],
    };
  }

  Future<void> clearClientSession() async {
    await _storage.deleteAll();
  }
}
