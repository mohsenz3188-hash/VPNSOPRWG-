import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/create_user_request.dart';
import '../models/user_session_model.dart';

class PasargadApiException implements Exception {
  final String message;
  final int? statusCode;
  const PasargadApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class PasargadApiService {
  late final Dio _dio;

  PasargadApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 12),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  Future<UserSessionModel> loginAndFetchConfig({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/client/auth/login',
        data: {
          'username': username.trim(),
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : (response.data['data'] as Map<String, dynamic>);
        return UserSessionModel.fromJson(data);
      }
      throw PasargadApiException(
        'Unexpected server response (${response.statusCode})',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e, defaultMsg: 'Failed to authenticate with Pasargad Panel.');
    }
  }

  Future<UserSessionModel> fetchUserStatus({
    required String accessToken,
    required String username,
  }) async {
    try {
      final response = await _dio.get(
        '/client/user/$username/status',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : (response.data['data'] as Map<String, dynamic>);
        return UserSessionModel.fromJson(data, fallbackToken: accessToken);
      }
      throw PasargadApiException(
        'Failed to fetch user traffic status.',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e, defaultMsg: 'Unable to sync quota with Pasargad Panel.');
    }
  }

  Future<Map<String, dynamic>> createWireGuardUser(CreateUserRequest request) async {
    try {
      final response = await _dio.post(
        '/admin/users/create',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConstants.panelAdminApiKey}',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : {'status': 'created', 'username': request.username};
      }
      throw PasargadApiException(
        'Failed to create user (HTTP ${response.statusCode})',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e, defaultMsg: 'Could not create user on Pasargad Panel.');
    }
  }

  PasargadApiException _handleDioError(DioException e, {required String defaultMsg}) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;
    String serverMessage = defaultMsg;

    if (responseData is Map<String, dynamic>) {
      serverMessage = (responseData['detail'] ??
              responseData['message'] ??
              responseData['error'] ??
              defaultMsg)
          .toString();
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      serverMessage = 'Connection to Pasargad Panel timed out. Check your internet connection.';
    } else if (e.type == DioExceptionType.connectionError) {
      serverMessage = 'Cannot reach Pasargad Panel server.';
    }

    return PasargadApiException(serverMessage, statusCode: statusCode);
  }
}
