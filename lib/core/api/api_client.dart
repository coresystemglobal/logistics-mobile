import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'token_storage.dart';
import 'api_exception.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;

  // Separate Dio instance for refresh calls (no auth interceptor)
  late final Dio _refreshDio;

  ApiClient._internal() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:4000/api';

    _refreshDio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 120),
    ));

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 120),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onResponse: _onResponse,
      onError: _onError,
    ));
  }

  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  Dio get dio => _dio;

  void _onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await TokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  void _onError(DioException err, ErrorInterceptorHandler handler) async {
    debugPrint('[API ERROR] ${err.requestOptions.method} ${err.requestOptions.path} → ${err.response?.statusCode} ${err.message}');
    if (err.response?.data != null) {
      debugPrint('[API ERROR] response body: ${err.response?.data}');
    }
    debugPrint('[API ERROR] request body: ${err.requestOptions.data}');

    final statusCode = err.response?.statusCode;
    final errorBody = err.response?.data;
    final isInvalidToken = statusCode == 403 &&
        errorBody is Map &&
        (errorBody['error'] == 'Invalid token');
    final isAuthEndpoint = err.requestOptions.path.contains('/auth/login') ||
        err.requestOptions.path.contains('/auth/register');

    if ((statusCode == 401 || isInvalidToken) && !isAuthEndpoint) {
      // Try token refresh
      try {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          // Retry original request with new token
          final token = await TokenStorage.getAccessToken();
          err.requestOptions.headers['Authorization'] = 'Bearer $token';
          final response = await _dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        }
      } catch (_) {}
      await TokenStorage.clearTokens();
    }
    handler.next(err);
  }

  Future<bool> _tryRefreshToken() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await _refreshDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final data = response.data;
      if (data['access_token'] != null) {
        await TokenStorage.saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'] ?? refreshToken,
        );
        return true;
      }
    } catch (_) {}
    return false;
  }

  ApiException _mapError(DioException err) {
    final data = err.response?.data;
    final validationErrors = data is Map ? (data['validation_errors'] as List?)?.map((e) => e['message'] as String).join(', ') : null;
    final message = validationErrors ??
        (data is Map ? data['error'] ?? data['message'] : null) ??
        err.message ??
        'An error occurred';

    switch (err.response?.statusCode) {
      case 401:
        return UnauthorizedException(message);
      case 403:
        return ForbiddenException(message);
      case 404:
        return NotFoundException(message);
      case 422:
        return ValidationException(message,
            errors: data is Map ? data['details'] : null);
      case null:
        return NetworkException(message);
      default:
        return ApiException(message, statusCode: err.response?.statusCode);
    }
  }

  Future<Map<String, dynamic>> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response =
          await _dio.get(path, queryParameters: queryParameters);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> post(String path,
      {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> put(String path,
      {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> patch(String path,
      {dynamic data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> postFormData(
      String path, FormData formData) async {
    try {
      final response = await _dio.post(path, data: formData);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }
}
