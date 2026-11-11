import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/storage/secure_storage_service.dart';
import '../data/models/create_user_request.dart';
import '../data/models/user_session_model.dart';
import '../data/services/pasargad_api_service.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final pasargadApiProvider = Provider<PasargadApiService>((ref) {
  return PasargadApiService();
});

class AuthState {
  final bool isLoading;
  final bool isAdminAuthenticated;
  final UserSessionModel? clientSession;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.isAdminAuthenticated = false,
    this.clientSession,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAdminAuthenticated,
    UserSessionModel? clientSession,
    bool clearClientSession = false,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAdminAuthenticated: isAdminAuthenticated ?? this.isAdminAuthenticated,
      clientSession: clearClientSession ? null : (clientSession ?? this.clientSession),
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final PasargadApiService _apiService;
  final SecureStorageService _storageService;

  AuthNotifier(this._apiService, this._storageService) : super(const AuthState()) {
    restoreSavedSession();
  }

  Future<void> restoreSavedSession() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final saved = await _storageService.getSavedCredentials();
      final username = saved['username'];
      final password = saved['password'];

      if (username != null &&
          username.isNotEmpty &&
          password != null &&
          password.isNotEmpty) {
        final session = await _apiService.loginAndFetchConfig(
          username: username,
          password: password,
        );
        await _storageService.saveClientSession(
          username: username,
          password: password,
          token: session.accessToken,
          wgConfig: session.wgQuickConfig,
          serverAddress: session.serverEndpoint,
        );
        state = state.copyWith(isLoading: false, clientSession: session);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: null);
    }
  }

  Future<bool> loginClient({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final session = await _apiService.loginAndFetchConfig(
        username: username,
        password: password,
      );

      await _storageService.saveClientSession(
        username: username,
        password: password,
        token: session.accessToken,
        wgConfig: session.wgQuickConfig,
        serverAddress: session.serverEndpoint,
      );

      state = state.copyWith(isLoading: false, clientSession: session);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> refreshClientQuota() async {
    final current = state.clientSession;
    if (current == null) return;

    try {
      final updated = await _apiService.fetchUserStatus(
        accessToken: current.accessToken,
        username: current.username,
      );
      state = state.copyWith(clientSession: updated);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  bool authenticateAdmin(String inputPassword) {
    if (inputPassword == AppConstants.adminMasterPassword) {
      state = state.copyWith(isAdminAuthenticated: true, errorMessage: null);
      return true;
    } else {
      state = state.copyWith(
        isAdminAuthenticated: false,
        errorMessage: 'Invalid Admin Master Password.',
      );
      return false;
    }
  }

  Future<bool> adminCreateUser({
    required String username,
    required String password,
    required int dataLimitGb,
  }) async {
    if (!state.isAdminAuthenticated) {
      state = state.copyWith(errorMessage: 'Unauthorized admin session.');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final req = CreateUserRequest(
        username: username,
        password: password,
        dataLimitGb: dataLimitGb,
      );
      await _apiService.createWireGuardUser(req);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _storageService.clearClientSession();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(pasargadApiProvider),
    ref.watch(secureStorageProvider),
  );
});
